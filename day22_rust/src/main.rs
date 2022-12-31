use std::iter::from_fn;

struct Transition {
    src: (Vec<Point>, Dir),
    dst: (Vec<Point>, Dir),
}

#[derive(Copy, Clone, Debug)]
struct Point {
    x: usize,
    y: usize,
}

impl Transition {
    fn new(src: (Vec<Point>, Dir), dst: (Vec<Point>, Dir)) -> Self {
        Self { src, dst }
    }

    fn rev(&self) -> Self {
        let src = (self.dst.0.clone(), self.dst.1.flip());
        let dst = (self.src.0.clone(), self.src.1.flip());
        Self { src, dst }
    }
}
// ([(99,0)..(99, 49)],
// ([(100,0)..(100,49)], Right)

//struct 2to4 {
//    points: Vec<Point>, // [(99,0)..(99, 49)]
//    src_direction: Facing, // Right,
//    dest_edge: (Vec<Point>, Facing), // ([(99,100)..(49,149)], Left)
//}

fn transitions() -> Vec<Transition> {
    [
        // 1 -> 2 (right of 1 -> left of 2)
        Transition::new(
            (range((99, 0), (99, 49)), RIGHT),
            (range((100, 0), (100, 49)), RIGHT),
        ),
        // 2 -> 4 (right of 2 -> left of 4)
        Transition::new(
            (range((149, 0), (149, 49)), RIGHT),
            (range((99, 100), (99, 149)), LEFT),
        ),
        // 1 -> 3 (bottom of 1 -> top of 3)
        Transition::new(
            (range((50, 49), (99, 49)), DOWN),
            (range((50, 50), (99, 50)), DOWN),
        ),
    ]
    .into_iter()
    .flat_map(|t| [t.rev(), t])
    .collect()
}

impl From<(usize, usize)> for Point {
    fn from((x, y): (usize, usize)) -> Self {
        Self { x, y }
    }
}

type Range = Vec<Point>;
fn range(src: impl Into<Point>, dst: impl Into<Point>) -> Range {
    let src = src.into();
    let dst = dst.into();
    let mut range = Vec::new();
    let mut x = src.x as isize;
    let mut y = src.y as isize;
    let dx: isize = if src.x < dst.x { 1 } else { -1 };
    let dy: isize = if src.y < dst.y { 1 } else { -1 };
    while x as usize != dst.x || y as usize != dst.y {
        range.push(Point {
            x: x as _,
            y: y as _,
        });
        x += dx;
        y += dy;
    }
    range.push(dst);
    range
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

#[allow(unused)]
fn print_grid(g: &Vec<Vec<char>>, cur: Point) {
    for (y, row) in g.iter().enumerate() {
        for (x, c) in row.iter().enumerate() {
            if x == cur.x && y == cur.y {
                print!("C");
            } else {
                print!("{}", c);
            }
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
    for inst in Inst::iter_from(instrs) {
        match inst {
            Inst::Move(mut n) => {
                // println!("Move {} {}", n, facing.to_string());
                match facing {
                    UP => {
                        let col = grid.col(pos.x);
                        let mut col_cycle = col
                            .iter()
                            .enumerate()
                            .rev()
                            .cycle()
                            .skip(col.len() - pos.y)
                            .filter(|(_, &c)| c != ' ')
                            .peekable();

                        let mut prev_y = pos.y;
                        while n > 0 {
                            let (y, &char) = col_cycle.next().unwrap();
                            if char == '.' {
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
                            .skip(row.len() - pos.x)
                            .filter(|(_, &c)| c != ' ');
                        let mut prev_x = pos.x;
                        while n > 0 {
                            let (x, &char) = row_cycle.next().unwrap();
                            if char == '.' {
                                g[pos.y][prev_x] = '<';
                                prev_x = x;
                                n -= 1;
                                continue;
                            } else if char == '#' {
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
                            if char == '.' {
                                g[prev_y][pos.x] = 'v';
                                prev_y = y;
                                n -= 1;
                                continue 'inner;
                            } else if char == '#' {
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
                // print_grid(&g, pos);
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
    // The final password is the sum of 1000 times the row,
    // 4 times the column, and the facing.
    let col = pos.x + 1;
    let row = pos.y + 1;
    let part1 = (1000 * row) + (4 * col) + facing.0 as usize;
    dbg!(part1);
}

#[derive(PartialEq, Eq, Debug, Clone, Copy)]
struct Dir(u8);

const UP: Dir = Dir(3);
const LEFT: Dir = Dir(2);
const DOWN: Dir = Dir(1);
const RIGHT: Dir = Dir(0);

impl Dir {
    fn flip(self) -> Self {
        match self {
            UP => DOWN,
            LEFT => RIGHT,
            DOWN => UP,
            RIGHT => LEFT,
            _ => unimplemented!(),
        }
    }

    fn turn_right(self) -> Self {
        Self((self.0 + 1) % 4)
    }

    fn turn_left(self) -> Self {
        Self((self.0 + 3) % 4)
    }

    #[allow(unused)]
    fn to_string(&self) -> &str {
        match *self {
            UP => "up",
            LEFT => "left",
            DOWN => "down",
            RIGHT => "right",
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

#[allow(unused)]
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
