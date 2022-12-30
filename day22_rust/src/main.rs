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
    fn from_rows(rows: &Vec<Vec<char>>) -> Self {
        let cols = rows
            .iter()
            .map(|row| row.iter().cloned().collect())
            .collect();
        Grid {
            rows: rows.clone(),
            cols,
        }
    }

    fn row(&self, y: usize) -> &[char] {
        &self.rows[y]
    }

    fn col(&self, x: usize) -> &[char] {
        &self.cols[x]
    }
}

fn main() {
    let (gridlines, instrs) = SAMPLE.split_once("\n\n").unwrap();
    let g: Vec<Vec<char>> = gridlines
        .trim_end()
        .lines()
        .map(|l| l.trim_end().chars().collect())
        .collect();

    let grid = Grid::from_rows(&g);

    let mut dir = RIGHT;
    let mut pos = Point {
        x: grid.row(0).iter().position(|&c| c == '.').unwrap(),
        y: 0,
    };
    dbg!(pos);
    for inst in Inst::iter_from(instrs) {
        match inst {
            Inst::Move(mut n) => match dir {
                UP => todo!(),
                LEFT => todo!(),
                DOWN => todo!(),
                RIGHT => {
                    let row = grid.row(pos.y);
                    let mut row_cycle = row.iter().enumerate().cycle().skip(pos.x + 1);
                    let mut num_moved = 0;
                    while n > 0 {
                        let (x, &char) = row_cycle.next().unwrap();
                        if char == ' ' {
                            num_moved += 1;
                            continue;
                        }
                        if char == '.' {
                            num_moved += 1;
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
            },
            Inst::Turn(turn) => match turn {
                'L' => dir = dir.turn_left(),
                'R' => dir = dir.turn_right(),
                _ => unreachable!(),
            },
        }
    }
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
