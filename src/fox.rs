use crossterm::cursor::{Hide, MoveTo, Show};
use crossterm::event::{self, Event, KeyCode, KeyEvent, KeyModifiers};
use crossterm::execute;
use crossterm::style::{
    Attribute, Color, ResetColor, SetAttribute, SetBackgroundColor, SetForegroundColor,
};
use crossterm::terminal::{self, Clear, ClearType, EnterAlternateScreen, LeaveAlternateScreen};
use std::env;
use std::fs;
use std::io::{self, Read, Stdout, Write};
use std::path::{Path, PathBuf};
use std::time::Duration;

struct Editor {
    file: PathBuf,
    syntax: Syntax,
    lines: Vec<String>,
    row: usize,
    column: usize,
    offset: usize,
    dirty: bool,
    message: String,
}

impl Editor {
    fn open(file: PathBuf) -> io::Result<Self> {
        let mut contents = String::new();
        if file.exists() {
            fs::File::open(&file)?.read_to_string(&mut contents)?;
        }
        let mut lines: Vec<String> = contents.split('\n').map(str::to_owned).collect();
        if lines.is_empty() {
            lines.push(String::new());
        }
        Ok(Self {
            syntax: Syntax::for_path(&file),
            file,
            lines,
            row: 0,
            column: 0,
            offset: 0,
            dirty: false,
            message: String::from(
                "Ctrl + H: Help - Ctrl + S: Save - Ctrl + W: Where - Ctrl + X: Exit",
            ),
        })
    }
    fn save(&mut self) -> io::Result<()> {
        let contents = self.lines.join("\n");
        fs::write(&self.file, contents)?;
        self.dirty = false;
        self.message = format!("File saved: {}", self.file.display());
        Ok(())
    }
    fn move_cursor(&mut self, code: KeyCode) {
        match code {
            KeyCode::Up => self.row = self.row.saturating_sub(1),
            KeyCode::Down => self.row = (self.row + 1).min(self.lines.len() - 1),
            KeyCode::Left => {
                if self.column > 0 {
                    self.column -= 1;
                } else if self.row > 0 {
                    self.row -= 1;
                    self.column = self.lines[self.row].len();
                }
            }
            KeyCode::Right => {
                if self.column < self.lines[self.row].len() {
                    self.column += 1;
                } else if self.row + 1 < self.lines.len() {
                    self.row += 1;
                    self.column = 0;
                }
            }
            KeyCode::Home => self.column = 0,
            KeyCode::End => self.column = self.lines[self.row].len(),
            _ => {}
        }
        self.column = self.column.min(self.lines[self.row].len());
    }
    fn insert(&mut self, character: char) {
        self.lines[self.row].insert(self.column, character);
        self.column += character.len_utf8();
        self.dirty = true;
    }
    fn newline(&mut self) {
        let remainder = self.lines[self.row].split_off(self.column);
        self.lines.insert(self.row + 1, remainder);
        self.row += 1;
        self.column = 0;
        self.dirty = true;
    }
    fn backspace(&mut self) {
        if self.column > 0 {
            let previous = self.lines[self.row][..self.column]
                .char_indices()
                .last()
                .map(|(index, _)| index)
                .unwrap_or(0);
            self.lines[self.row].drain(previous..self.column);
            self.column = previous;
        } else if self.row > 0 {
            let current = self.lines.remove(self.row);
            self.row -= 1;
            self.column = self.lines[self.row].len();
            self.lines[self.row].push_str(&current);
        } else {
            return;
        }
        self.dirty = true;
    }
    fn delete(&mut self) {
        if self.column < self.lines[self.row].len() {
            let end = self.lines[self.row][self.column..]
                .char_indices()
                .nth(1)
                .map(|(index, _)| self.column + index)
                .unwrap_or(self.lines[self.row].len());
            self.lines[self.row].drain(self.column..end);
        } else if self.row + 1 < self.lines.len() {
            let next = self.lines.remove(self.row + 1);
            self.lines[self.row].push_str(&next);
        } else {
            return;
        }
        self.dirty = true;
    }
    fn search(&mut self, stdout: &mut Stdout) -> io::Result<()> {
        let query = prompt(stdout, "Search: ")?;
        if query.is_empty() {
            return Ok(());
        }
        let start = self.row + 1;
        let found = (start..self.lines.len())
            .chain(0..=self.row)
            .find(|&index| self.lines[index].contains(&query));
        match found {
            Some(index) => {
                self.row = index;
                self.column = self.lines[index].find(&query).unwrap_or(0);
                self.message = format!("Found: {}", query);
            }
            None => self.message = format!("Not found: {}", query),
        }
        Ok(())
    }
    fn draw(&mut self, stdout: &mut Stdout) -> io::Result<()> {
        let (width, height) = terminal::size()?;
        let text_height = height.saturating_sub(2) as usize;
        if self.row < self.offset {
            self.offset = self.row;
        } else if self.row >= self.offset + text_height {
            self.offset = self.row.saturating_sub(text_height.saturating_sub(1));
        }
        execute!(stdout, MoveTo(0, 0), Clear(ClearType::All))?;
        for screen_row in 0..text_height {
            let line_index = self.offset + screen_row;
            execute!(stdout, MoveTo(0, screen_row as u16))?;
            if line_index < self.lines.len() {
                let line = &self.lines[line_index];
                let available = width.saturating_sub(1) as usize;
                draw_highlighted_line(stdout, line, available, self.syntax)?;
            }
        }
        let bar_width = width as usize;
        let title = format!(
            "{}{}",
            self.file.display(),
            if self.dirty { " *" } else { "" }
        );
        let title = center_text(&title, bar_width);
        execute!(
            stdout,
            MoveTo(0, height.saturating_sub(2)),
            SetBackgroundColor(Color::DarkBlue),
            SetForegroundColor(Color::White),
            SetAttribute(Attribute::Bold)
        )?;
        write!(stdout, "{title}")?;
        execute!(
            stdout,
            SetAttribute(Attribute::Reset),
            MoveTo(0, height.saturating_sub(1)),
            SetBackgroundColor(Color::DarkBlue),
            SetForegroundColor(Color::White)
        )?;
        let message = center_text(&self.message, bar_width);
        write!(stdout, "{message}")?;
        execute!(stdout, ResetColor)?;
        let cursor_x = self.column.min(width.saturating_sub(1) as usize) as u16;
        let cursor_y = self
            .row
            .saturating_sub(self.offset)
            .min(text_height.saturating_sub(1)) as u16;
        execute!(stdout, MoveTo(cursor_x, cursor_y), Show)?;
        stdout.flush()
    }
}

#[derive(Clone, Copy)]
struct Syntax {
    keyword: Color,
    string: Color,
    comment: Color,
}

impl Syntax {
    fn for_path(path: &Path) -> Self {
        match path.extension().and_then(|extension| extension.to_str()) {
            Some("rs") => Self {
                keyword: Color::Blue,
                string: Color::Yellow,
                comment: Color::DarkGrey,
            },
            Some("sh" | "bash" | "zsh") => Self {
                keyword: Color::Green,
                string: Color::Yellow,
                comment: Color::DarkGrey,
            },
            Some("c" | "h" | "cc" | "cpp" | "hpp") => Self {
                keyword: Color::Magenta,
                string: Color::Yellow,
                comment: Color::DarkGrey,
            },
            Some("py") => Self {
                keyword: Color::Blue,
                string: Color::Green,
                comment: Color::DarkGrey,
            },
            Some("js" | "jsx" | "ts" | "tsx") => Self {
                keyword: Color::Cyan,
                string: Color::Yellow,
                comment: Color::DarkGrey,
            },
            Some("html" | "htm" | "xml" | "css") => Self {
                keyword: Color::Red,
                string: Color::Green,
                comment: Color::DarkGrey,
            },
            Some("toml" | "yaml" | "yml" | "json" | "conf") => Self {
                keyword: Color::Cyan,
                string: Color::Green,
                comment: Color::DarkGrey,
            },
            _ => Self {
                keyword: Color::Blue,
                string: Color::Yellow,
                comment: Color::DarkGrey,
            },
        }
    }
}

fn draw_highlighted_line(
    stdout: &mut Stdout,
    line: &str,
    width: usize,
    syntax: Syntax,
) -> io::Result<()> {
    let characters: Vec<char> = line.chars().take(width).collect();
    let mut index = 0;
    while index < characters.len() {
        if is_comment_start(&characters, index) {
            execute!(stdout, SetForegroundColor(syntax.comment))?;
            for character in &characters[index..] {
                write!(stdout, "{character}")?;
            }
            break;
        }
        if characters[index] == '"' || characters[index] == '\'' || characters[index] == '`' {
            let quote = characters[index];
            execute!(stdout, SetForegroundColor(syntax.string))?;
            write!(stdout, "{quote}")?;
            index += 1;
            while index < characters.len() {
                let character = characters[index];
                write!(stdout, "{character}")?;
                if character == quote && characters.get(index.saturating_sub(1)) != Some(&'\\') {
                    index += 1;
                    break;
                }
                index += 1;
            }
            execute!(stdout, ResetColor)?;
            continue;
        }
        if characters[index].is_ascii_digit() {
            execute!(stdout, SetForegroundColor(Color::Cyan))?;
            while index < characters.len()
                && (characters[index].is_ascii_digit() || characters[index] == '.')
            {
                write!(stdout, "{}", characters[index])?;
                index += 1;
            }
            execute!(stdout, ResetColor)?;
            continue;
        }
        if characters[index].is_ascii_alphabetic() || characters[index] == '_' {
            let start = index;
            while index < characters.len()
                && (characters[index].is_ascii_alphanumeric() || characters[index] == '_')
            {
                index += 1;
            }
            let word: String = characters[start..index].iter().collect();
            if is_keyword(&word) {
                execute!(stdout, SetForegroundColor(syntax.keyword))?;
                write!(stdout, "{word}")?;
                execute!(stdout, ResetColor)?;
            } else {
                write!(stdout, "{word}")?;
            }
            continue;
        }
        write!(stdout, "{}", characters[index])?;
        index += 1;
    }
    execute!(stdout, ResetColor)
}

fn is_comment_start(characters: &[char], index: usize) -> bool {
    characters[index] == '#'
        || (characters[index] == '/' && characters.get(index + 1) == Some(&'/'))
        || (characters[index] == '/' && characters.get(index + 1) == Some(&'*'))
}

fn is_keyword(word: &str) -> bool {
    matches!(
        word,
        "as" | "async"
            | "await"
            | "break"
            | "case"
            | "class"
            | "const"
            | "continue"
            | "def"
            | "else"
            | "enum"
            | "export"
            | "false"
            | "fn"
            | "for"
            | "from"
            | "function"
            | "if"
            | "impl"
            | "import"
            | "in"
            | "let"
            | "match"
            | "mod"
            | "None"
            | "null"
            | "pub"
            | "return"
            | "self"
            | "struct"
            | "super"
            | "this"
            | "throw"
            | "true"
            | "type"
            | "use"
            | "var"
            | "while"
    )
}

fn center_text(text: &str, width: usize) -> String {
    let clipped: String = text.chars().take(width).collect();
    let padding = width.saturating_sub(clipped.chars().count());
    let left = padding / 2;
    let right = padding - left;
    format!("{}{}{}", " ".repeat(left), clipped, " ".repeat(right))
}

fn prompt(stdout: &mut Stdout, label: &str) -> io::Result<String> {
    let (_, height) = terminal::size()?;
    execute!(
        stdout,
        MoveTo(0, height.saturating_sub(1)),
        Clear(ClearType::CurrentLine)
    )?;
    write!(stdout, "{label}")?;
    stdout.flush()?;
    let mut input = String::new();
    loop {
        if let Event::Key(key) = event::read()? {
            match key.code {
                KeyCode::Enter => break,
                KeyCode::Esc => {
                    input.clear();
                    break;
                }
                KeyCode::Backspace => {
                    input.pop();
                }
                KeyCode::Char(character) if key.modifiers.is_empty() => input.push(character),
                _ => {}
            }
            execute!(
                stdout,
                MoveTo(label.len() as u16, height.saturating_sub(1)),
                Clear(ClearType::UntilNewLine)
            )?;
            write!(stdout, "{input}")?;
            stdout.flush()?;
        }
    }
    Ok(input)
}

fn main() -> io::Result<()> {
    let file = env::args_os()
        .nth(1)
        .map(PathBuf::from)
        .ok_or_else(|| {
            io::Error::new(io::ErrorKind::InvalidInput, "missing file path argument!")
        });
    let mut editor = Editor::open(file?)?;
    let mut stdout = io::stdout();
    terminal::enable_raw_mode()?;
    execute!(stdout, EnterAlternateScreen, Hide)?;
    let result = run(&mut editor, &mut stdout);
    terminal::disable_raw_mode()?;
    execute!(stdout, Show, LeaveAlternateScreen)?;
    result
}

fn run(editor: &mut Editor, stdout: &mut Stdout) -> io::Result<()> {
    loop {
        editor.draw(stdout)?;
        if !event::poll(Duration::from_millis(250))? {
            continue;
        }
        let Event::Key(KeyEvent {
            code, modifiers, ..
        }) = event::read()?
        else {
            continue;
        };
        if modifiers.contains(KeyModifiers::CONTROL) {
            match code {
                KeyCode::Char('x') => {
                    if editor.dirty
                        && prompt(stdout, "Save changes? (y/n): ")?.eq_ignore_ascii_case("y")
                    {
                        editor.save()?;
                        return Ok(());
                    } else {
                        return Ok(());
                    }
                }
                KeyCode::Char('s') => {
                    if let Err(error) = editor.save() {
                        editor.message = format!("Save failed: {}", error);
                    }
                }
                KeyCode::Char('w') => editor.search(stdout)?,
                KeyCode::Char('h') => {
                    editor.message = String::from(
                        "Ctrl + H: Help - Ctrl + S: Save - Ctrl + W: Where - Ctrl + X: Exit",
                    );
                }
                _ => {}
            }
        } else {
            match code {
                KeyCode::Up
                | KeyCode::Down
                | KeyCode::Left
                | KeyCode::Right
                | KeyCode::Home
                | KeyCode::End => editor.move_cursor(code),
                KeyCode::Backspace => editor.backspace(),
                KeyCode::Delete => editor.delete(),
                KeyCode::Enter => editor.newline(),
                KeyCode::Char(character) => editor.insert(character),
                _ => {}
            }
        }
    }
}
