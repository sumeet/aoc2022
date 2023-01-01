use std::cmp::Ordering;
use std::iter::from_fn;

struct Transition {
    name: String,
    src: (Range, Facing),
    dst: (Range, Facing),
}

impl Transition {
    fn map_src(&self, pt: Point, facing: Facing) -> Option<(Point, Facing)> {
        if self.src.1 != facing {
            return None;
        }
        let index = self.src.0.index(pt)?;
        Some((self.dst.0.nth(index), self.dst.1))
    }
}

#[derive(Copy, Clone, Debug, PartialEq)]
struct Point {
    x: usize,
    y: usize,
}

impl Point {
    fn apply(mut self, dir: Facing) -> Self {
        match dir {
            UP => self.y -= 1,
            DOWN => self.y += 1,
            LEFT => self.x -= 1,
            RIGHT => self.x += 1,
            _ => unimplemented!(),
        }
        self
    }

    fn is_between(&self, a: Self, b: Self) -> bool {
        let x = match (a.x.cmp(&self.x), b.x.cmp(&self.x)) {
            (Ordering::Less, Ordering::Greater) => true,
            (Ordering::Greater, Ordering::Less) => true,
            (Ordering::Equal, _) => true,
            (_, Ordering::Equal) => true,
            _ => false,
        };
        let y = match (a.y.cmp(&self.y), b.y.cmp(&self.y)) {
            (Ordering::Less, Ordering::Greater) => true,
            (Ordering::Greater, Ordering::Less) => true,
            (Ordering::Equal, _) => true,
            (_, Ordering::Equal) => true,
            _ => false,
        };
        x && y
    }
}

impl Transition {
    fn new(src: (Range, Facing), dst: (Range, Facing), name: String) -> Self {
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
        // 1 -> 5 (left of 1 -> left of 5, upside down)
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
        // 2 -> 4 (right of 2 -> right of 4 upside down)
        Transition::new(
            (range((149, 0), (149, 49)), RIGHT),
            (range((99, 149), (99, 100)), LEFT),
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
            (range((0, 100), (49, 100)), DOWN),
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

fn ordcmp(a: usize, b: usize) -> isize {
    match a.cmp(&b) {
        Ordering::Less => -1,
        Ordering::Equal => 0,
        Ordering::Greater => 1,
    }
}

fn search_transitions(
    point: impl Into<Point>,
    facing: Facing,
    transitions: &[Transition],
) -> Option<(Point, Facing)> {
    let point = point.into();
    for tran in transitions {
        if let Some(dst) = tran.map_src(point, facing) {
            return Some(dst);
        }
    }
    None
}

#[derive(Clone, Copy)]
struct Range {
    src: Point,
    dst: Point,
}

impl Range {
    fn index(&self, pt: Point) -> Option<usize> {
        if pt.is_between(self.src, self.dst) {
            Some(self.src.x.abs_diff(pt.x) + self.src.y.abs_diff(pt.y))
        } else {
            None
        }
    }

    fn nth(&self, index: usize) -> Point {
        let mut start = self.src;
        start.x = (start.x as isize + (ordcmp(self.dst.x, self.src.x) * index as isize)) as _;
        start.y = (start.y as isize + (ordcmp(self.dst.y, self.src.y) * index as isize)) as _;
        start
    }
}

fn range(src: impl Into<Point>, dst: impl Into<Point>) -> Range {
    Range {
        src: src.into(),
        dst: dst.into(),
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

fn next_pos(cur: Point, facing: Facing, transitions: &[Transition]) -> (Point, Facing) {
    if let Some(trans) = search_transitions(cur, facing, transitions) {
        trans
    } else {
        (cur.apply(facing), facing)
    }
}

fn main() {
    let transitions = transitions();

    let (gridlines, instrs) = INPUT.trim_end().split_once("\n\n").unwrap();
    let grid: Vec<Vec<char>> = gridlines
        .trim_end()
        .lines()
        .map(|l| l.trim_end().chars().collect())
        .collect();

    #[cfg(debug_assertions)]
    let mut debug_g = grid.clone();

    let mut facing = RIGHT;
    let mut pos = Point {
        x: grid[0].iter().position(|&c| c == '.').unwrap(),
        y: 0,
    };
    for inst in parse(instrs) {
        match inst {
            Inst::Move(n) => {
                // println!("Moving {} {}", n, facing.to_string());
                for _ in 0..n {
                    let (next_pos, next_dir) = next_pos(pos, facing, &transitions);
                    if grid[next_pos.y][next_pos.x] == '.' {
                        #[cfg(debug_assertions)]
                        {
                            debug_g[pos.y][pos.x] = match facing {
                                UP => '^',
                                DOWN => 'v',
                                RIGHT => '>',
                                LEFT => '<',
                                _ => unreachable!(),
                            };
                        }

                        pos = next_pos;
                        facing = next_dir;
                    }
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
    let col = pos.x + 1;
    let row = pos.y + 1;
    let part2 = (1000 * row) + (4 * col) + facing.0 as usize;
    dbg!(part2);
}

#[derive(PartialEq, Eq, Debug, Clone, Copy)]
struct Facing(u8);

const UP: Facing = Facing(3);
const LEFT: Facing = Facing(2);
const DOWN: Facing = Facing(1);
const RIGHT: Facing = Facing(0);

impl Facing {
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

fn parse(s: &str) -> impl Iterator<Item = Inst> + '_ {
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

const INPUT: &str = include_str!("input.txt");
