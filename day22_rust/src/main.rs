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
        let cols = transpose(rows.clone());
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
    let (gridlines, instrs) = SAMPLE.split_once("\n\n").unwrap();
    let mut g: Vec<Vec<char>> = gridlines
        .trim_end()
        .lines()
        .map(|l| l.trim_end().chars().collect())
        .collect();

    let grid = Grid::from_rows(g.clone());

    let mut dir = RIGHT;
    let mut pos = Point {
        x: grid.row(0).iter().position(|&c| c == '.').unwrap(),
        y: 0,
    };
    for inst in Inst::iter_from(instrs) {
        match inst {
            Inst::Move(mut n) => {
                println!("Move {} {}", n, dir.to_string());
                match dir {
                    UP => {
                        let col = grid.col(pos.x);
                        let mut col_cycle = col
                            .iter()
                            .enumerate()
                            .rev()
                            .cycle()
                            .filter(|(_, &c)| c != ' ')
                            .skip(col.len() - pos.y - 1);
                        let mut num_moved = 0;
                        let mut prev_y = pos.y;
                        while n > 0 {
                            let (y, &char) = col_cycle.next().unwrap();
                            if char == ' ' {
                                num_moved += 1;
                                g[prev_y][pos.x] = '^';
                                prev_y = y;
                                continue;
                            } else if char == '.' {
                                num_moved += 1;
                                g[prev_y][pos.x] = '^';
                                prev_y = y;
                                n -= 1;
                                continue;
                            } else if char == '#' {
                                break;
                            }
                        }
                        pos.y = (pos.y - num_moved) % col.len();
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
                        let mut num_moved = 0;
                        let mut prev_x = pos.x;
                        while n > 0 {
                            let (x, &char) = row_cycle.next().unwrap();
                            if char == ' ' {
                                num_moved += 1;
                                g[pos.y][prev_x] = '<';
                                prev_x = x;
                                continue;
                            }
                            if char == '.' {
                                num_moved += 1;
                                g[pos.y][prev_x] = '<';
                                prev_x = x;
                                n -= 1;
                                continue;
                            }
                            if char == '#' {
                                break;
                            }
                        }
                        pos.x = (pos.x - num_moved) % row.len();
                    }
                    DOWN => {
                        let col = grid.col(pos.x);
                        let mut col_cycle = col
                            .iter()
                            .enumerate()
                            .cycle()
                            .skip(pos.y + 1)
                            .filter(|(_, &c)| c != ' ');
                        let mut num_moved = 0;
                        let mut prev_y = pos.y;
                        'inner: while n > 0 {
                            let (y, &char) = col_cycle.next().unwrap();
                            if char == ' ' {
                                num_moved += 1;
                                g[prev_y][pos.x] = 'v';
                                prev_y = y;
                                continue 'inner;
                            }
                            if char == '.' {
                                num_moved += 1;
                                g[prev_y][pos.x] = 'v';
                                prev_y = y;
                                n -= 1;
                                continue 'inner;
                            }
                            if char == '#' {
                                break;
                            }
                        }
                        pos.y = (pos.y + num_moved) % col.len();
                    }
                    RIGHT => {
                        let row = grid.row(pos.y);
                        let mut row_cycle = row
                            .iter()
                            .enumerate()
                            .cycle()
                            .skip(pos.x + 1)
                            .filter(|(_, &c)| c != ' ');
                        let mut num_moved = 0;
                        let mut prev_x = pos.x;
                        while n > 0 {
                            let (x, &char) = row_cycle.next().unwrap();
                            if char == ' ' {
                                num_moved += 1;
                                g[pos.y][prev_x] = '>';
                                prev_x = x;
                                continue;
                            }
                            if char == '.' {
                                num_moved += 1;
                                g[pos.y][prev_x] = '>';
                                prev_x = x;
                                n -= 1;
                                continue;
                            }
                            if char == '#' {
                                break;
                            }
                        }
                        pos.x = (pos.x + num_moved) % row.len();
                    }
                    _ => unreachable!(),
                }
                print_grid(&g);
                println!();
                println!();
                println!();
            }
            Inst::Turn(turn) => match turn {
                'L' => dir = dir.turn_left(),
                'R' => dir = dir.turn_right(),
                _ => unreachable!(),
            },
        }
    }
    dbg!(pos);
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

fn transpose<T>(v: Vec<Vec<T>>) -> Vec<Vec<T>> {
    assert!(!v.is_empty());
    let len = v[0].len();
    let mut iters: Vec<_> = v.into_iter().map(|n| n.into_iter()).collect();
    (0..len)
        .map(|_| {
            iters
                .iter_mut()
                .map(|n| n.next().unwrap())
                .collect::<Vec<T>>()
        })
        .collect()
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
