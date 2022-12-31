use std::iter::from_fn;

struct Transition {
    name: String,
    src: (Vec<Point>, Dir),
    dst: (Vec<Point>, Dir),
}

#[derive(Copy, Clone, Debug, PartialEq)]
struct Point {
    x: usize,
    y: usize,
}

impl Point {
    fn apply(mut self, dir: Dir) -> Self {
        match dir {
            UP => self.y -= 1,
            DOWN => self.y += 1,
            LEFT => self.x -= 1,
            RIGHT => self.x += 1,
            _ => unimplemented!(),
        }
        self
    }
}

impl Transition {
    fn new(src: (Vec<Point>, Dir), dst: (Vec<Point>, Dir), name: String) -> Self {
        Self { src, dst, name }
    }

    fn rev(&self) -> Self {
        let src = (self.dst.0.clone(), self.dst.1.flip());
        let dst = (self.src.0.clone(), self.src.1.flip());
        Self {
            src,
            dst,
            name: format!("{}-rev", self.name),
        }
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
            "1 -> 2".into(),
        ),
        // 1 -> 3 (bottom of 1 -> top of 3)
        Transition::new(
            (range((50, 49), (99, 49)), DOWN),
            (range((50, 50), (99, 50)), DOWN),
            "1 -> 3".into(),
        ),
        // 1 -> 5 (left of 1 -> left of 5)
        Transition::new(
            (range((50, 0), (50, 49)), LEFT),
            (range((0, 149), (0, 100)), RIGHT),
            "1 -> 5".into(),
        ),
        // 1 -> 6 (top of 1, left of 6)
        Transition::new(
            (range((50, 0), (99, 0)), UP),
            (range((0, 150), (0, 199)), RIGHT),
            "1 -> 6".into(),
        ),
        // 2 -> 3 (bottom of 2 -> right of 3)
        Transition::new(
            (range((100, 49), (149, 49)), DOWN),
            (range((99, 50), (99, 99)), LEFT),
            "2 -> 3".into(),
        ),
        // 2 -> 4 (right of 2 -> right of 4)
        Transition::new(
            (range((149, 49), (149, 0)), RIGHT),
            (range((99, 100), (99, 149)), LEFT),
            "2 -> 4".into(),
        ),
        // 2 -> 6 (top of 2 -> bottom of 6)
        Transition::new(
            (range((100, 0), (149, 0)), UP),
            (range((0, 199), (49, 199)), UP),
            "2 -> 6".into(),
        ),
        // 3 -> 4 (bottom of 3 -> top of 4)
        Transition::new(
            (range((50, 99), (99, 99)), DOWN),
            (range((50, 100), (99, 100)), DOWN),
            "3 -> 4".into(),
        ),
        // 3 -> 5 (left of 3 -> top of 5)
        Transition::new(
            (range((50, 50), (50, 99)), LEFT),
            (range((0, 100), (0, 149)), DOWN),
            "3 -> 5".into(),
        ),
        // 4 -> 5 (left of 4, right of 5)
        Transition::new(
            (range((50, 100), (50, 149)), LEFT),
            (range((49, 100), (49, 149)), LEFT),
            "4 -> 5".into(),
        ),
        // 4 -> 6 (bottom of 4 -> right of 6)
        Transition::new(
            (range((50, 149), (99, 149)), DOWN),
            (range((49, 150), (49, 199)), LEFT),
            "4 -> 6".into(),
        ),
        // 5 -> 6 (bottom of 5, top of 6)
        Transition::new(
            (range((0, 149), (49, 149)), DOWN),
            (range((0, 150), (49, 150)), DOWN),
            "5 -> 6".into(),
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

fn search_transitions(
    point: impl Into<Point>,
    dir: Dir,
    transitions: &[Transition],
) -> Option<(Point, Dir)> {
    let point = point.into();
    for tran in transitions {
        if dir != tran.src.1 {
            continue;
        }
        for (i, trans_pt) in tran.src.0.iter().enumerate() {
            if point == *trans_pt {
                println!("found transition {}", tran.name);
                return Some((tran.dst.0[i], tran.dst.1));
            }
        }
    }
    None
    // let src_transition = transitions
    //     .iter()
    //     .find(|t| t.src.0.contains(&point) && t.src.1 == dir)?;
    // let i = src_transition
    //     .src
    //     .0
    //     .iter()
    //     .position(|p| *p == point)
    //     .unwrap();
    // let dst_point = src_transition.dst.0[i];
    // Some((dst_point, src_transition.dst.1))
}

type Range = Vec<Point>;
fn range(src: impl Into<Point>, dst: impl Into<Point>) -> Range {
    let src = src.into();
    let dst = dst.into();
    let mut range = Vec::new();
    let mut x = src.x as isize;
    let mut y = src.y as isize;
    let dx: isize = if src.x < dst.x {
        1
    } else if src.x > dst.x {
        -1
    } else {
        0
    };
    let dy: isize = if src.y < dst.y {
        1
    } else if src.y > dst.y {
        -1
    } else {
        0
    };
    while x as usize != dst.x || y as usize != dst.y {
        range.push(Point {
            x: x as _,
            y: y as _,
        });
        x += dx;
        y += dy;
    }
    range.push(dst);
    assert_eq!(range.len(), 50);
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

fn next_pos(cur: Point, dir: Dir, transitions: &[Transition]) -> (Point, Dir) {
    if let Some(trans) = search_transitions(cur, dir, transitions) {
        println!(
            "got edge on: {:?} -> {:?}",
            (cur.x, cur.y),
            (trans.0.x, trans.0.y)
        );
        trans
    } else {
        println!("not edge");
        (cur.apply(dir), dir)
    }
}

fn main() {
    let transitions = transitions();
    // assert_eq!(transitions.len(), 24);

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
                println!("Moving {} {}", n, facing.to_string());
                for _ in 0..n {
                    let (next_pos, next_dir) = next_pos(pos, facing, &transitions);
                    if grid.row(next_pos.y)[next_pos.x] == '.' {
                        g[pos.y][pos.x] = match facing {
                            UP => '^',
                            DOWN => 'v',
                            RIGHT => '>',
                            LEFT => '<',
                            _ => unreachable!(),
                        };

                        pos = next_pos;
                        facing = next_dir;
                    }
                    println!("next: {:?}", (pos.x, pos.y));
                }

                print_grid(&g, pos);
                println!();
                println!();
                println!();
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
