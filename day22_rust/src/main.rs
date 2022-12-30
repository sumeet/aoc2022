use std::iter::from_fn;

#[derive(Copy, Clone, Debug)]
struct Point {
    x: usize,
    y: usize,
}

#[derive(Debug)]
struct Grid {
    rows: Vec<Vec<char>>,
    cols: Vec<Vec<char>>,
}

impl Grid {
    fn from_rows(rows: Vec<Vec<char>>) -> Self {
        let cols = transpose(&rows);
        Grid { rows, cols }
    }

    fn row(&self, y: usize) -> &[char] {
        &self.rows[y]
    }

    fn col(&self, x: usize) -> &[char] {
        &self.cols[x]
    }
}

fn print_grid(g: &Vec<Vec<char>>) {
    for row in g {
        for c in row {
            print!("{}", c);
        }
        println!();
    }
}

fn main() {
    let (gridlines, instrs) = INPUT.trim_end().split_once("\n\n").unwrap();
    let mut g: Vec<Vec<char>> = gridlines
        .trim_end()
        .lines()
        .map(|l| l.trim_end().chars().collect())
        .collect();

    let grid = Grid::from_rows(g.clone());

    let mut facing = RIGHT;
    let mut pos = Point {
        x: grid.row(0).iter().position(|&c| c == '.').unwrap(),
        y: 0,
    };
    dbg!(pos);
    for inst in Inst::iter_from(instrs) {
        match inst {
            Inst::Move(mut n) => {
                // println!("Move {} {}", n, dir.to_string());
                match facing {
                    UP => {
                        let col = grid.col(pos.x);
                        let mut col_cycle = col
                            .iter()
                            .enumerate()
                            .rev()
                            .cycle()
                            .filter(|(_, &c)| c != ' ')
                            .skip(col.len() - pos.y - 1);
                        let mut prev_y = pos.y;
                        while n > 0 {
                            let (y, &char) = col_cycle.next().unwrap();
                            if char == ' ' {
                                g[prev_y][pos.x] = '^';
                                prev_y = y;
                                continue;
                            } else if char == '.' {
                                g[prev_y][pos.x] = '^';
                                prev_y = y;
                                n -= 1;
                                continue;
                            } else if char == '#' {
                                break;
                            }
                        }
                        pos.y = prev_y;
                    }
                    LEFT => {
                        let row = grid.row(pos.y);
                        let mut row_cycle = row
                            .iter()
                            .enumerate()
                            .rev()
                            .cycle()
                            .filter(|(_, &c)| c != ' ')
                            .skip(row.len() - pos.x - 1);
                        let mut prev_x = pos.x;
                        while n > 0 {
                            let (x, &char) = row_cycle.next().unwrap();
                            if char == ' ' {
                                g[pos.y][prev_x] = '<';
                                prev_x = x;
                                continue;
                            }
                            if char == '.' {
                                g[pos.y][prev_x] = '<';
                                prev_x = x;
                                n -= 1;
                                continue;
                            }
                            if char == '#' {
                                break;
                            }
                        }
                        pos.x = prev_x;
                    }
                    DOWN => {
                        let col = grid.col(pos.x);
                        let mut col_cycle = col
                            .iter()
                            .enumerate()
                            .cycle()
                            .skip(pos.y + 1)
                            .filter(|(_, &c)| c != ' ');
                        let mut prev_y = pos.y;
                        'inner: while n > 0 {
                            let (y, &char) = col_cycle.next().unwrap();
                            if char == ' ' {
                                g[prev_y][pos.x] = 'v';
                                prev_y = y;
                                continue 'inner;
                            }
                            if char == '.' {
                                g[prev_y][pos.x] = 'v';
                                prev_y = y;
                                n -= 1;
                                continue 'inner;
                            }
                            if char == '#' {
                                break;
                            }
                        }
                        pos.y = prev_y;
                    }
                    RIGHT => {
                        let row = grid.row(pos.y);
                        let mut row_cycle = row
                            .iter()
                            .enumerate()
                            .cycle()
                            .skip(pos.x + 1)
                            .filter(|(_, &c)| c != ' ');
                        let mut prev_x = pos.x;
                        while n > 0 {
                            let (x, &char) = row_cycle.next().unwrap();
                            if char == ' ' {
                                g[pos.y][prev_x] = '>';
                                prev_x = x;
                                continue;
                            }
                            if char == '.' {
                                g[pos.y][prev_x] = '>';
                                prev_x = x;
                                n -= 1;
                                continue;
                            }
                            if char == '#' {
                                break;
                            }
                        }
                        pos.x = prev_x;
                    }
                    _ => unreachable!(),
                }
                // print_grid(&g);
                // println!();
                // println!();
                // println!();
            }
            Inst::Turn(turn) => match turn {
                'L' => facing = facing.turn_left(),
                'R' => facing = facing.turn_right(),
                _ => unreachable!(),
            },
        }
    }
    let col = pos.x + 1;
    let row = pos.y + 1;
    // The final password is the sum of 1000 times the row,
    // 4 times the column, and the facing.
    dbg!((1000 * row) + (4 * col) + facing.0 as usize);

    // print_grid(&g);
}

#[derive(PartialEq, Eq, Debug)]
struct Dir(u8);

const UP: Dir = Dir(3);
const LEFT: Dir = Dir(2);
const DOWN: Dir = Dir(1);
const RIGHT: Dir = Dir(0);

impl Dir {
    fn turn_right(self) -> Self {
        Self((self.0 + 1) % 4)
    }

    fn turn_left(self) -> Self {
        Self((self.0 + 3) % 4)
    }

    fn to_string(&self) -> &str {
        match *self {
            UP => "UP",
            LEFT => "LEFT",
            DOWN => "DOWN",
            RIGHT => "RIGHT",
            _ => unreachable!(),
        }
    }
}

#[derive(Debug)]
enum Inst {
    Move(usize),
    Turn(char),
}

impl Inst {
    fn iter_from(s: &str) -> impl Iterator<Item = Self> + '_ {
        let mut i = s.chars().peekable();
        from_fn(move || {
            let mut next = i.next()?;
            let mut n = 0;
            while next.is_ascii_digit() {
                n = n * 10 + next.to_digit(10).unwrap() as usize;
                if i.peek().is_none() || !i.peek().unwrap().is_ascii_digit() {
                    let ret = Inst::Move(n);
                    return Some(ret);
                }
                next = i.next()?;
            }
            Some(Inst::Turn(next))
        })
    }
}

fn transpose(rows: &Vec<Vec<char>>) -> Vec<Vec<char>> {
    let mut cols = vec![];
    for i in 0.. {
        let mut is_totally_empty = true;
        let mut col = vec![];

        for row in rows {
            if let Some(&c) = row.get(i) {
                col.push(c);
                if c != ' ' {
                    is_totally_empty = false;
                }
            } else {
                col.push(' ');
            }
        }

        if !is_totally_empty {
            cols.push(col);
        } else {
            break;
        }
    }
    cols
}

const SAMPLE: &str = "        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5";

const INPUT: &str = include_str!("input.txt");
