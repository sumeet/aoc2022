use pathfinding::prelude::astar;

#[derive(Copy, Clone, Debug, PartialEq, Eq, Hash)]
struct Coord {
    x: usize,
    y: usize,
}

impl Coord {
    fn apply(self, dxdy: (isize, isize)) -> Option<Self> {
        Some(Self {
            x: self.x.checked_add_signed(dxdy.0)?,
            y: self.y.checked_add_signed(dxdy.1)?,
        })
    }

    fn dist(&self, other: &Self) -> usize {
        self.x.abs_diff(other.x) + self.y.abs_diff(other.y)
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
struct State {
    cur_pos: Coord,
    blizzards: Vec<(Coord, char)>,
}

impl State {
    #[allow(unused)]
    fn print(&self, grid: &[Vec<char>]) {
        for (y, row) in grid.iter().enumerate() {
            for (x, c) in row.iter().enumerate() {
                let coord = Coord { x, y };
                if let Some((_, c)) = self.blizzards.iter().find(|(c, _)| *c == coord) {
                    print!("{}", c);
                } else {
                    print!("{}", c);
                }
            }
            println!();
        }
    }

    fn nexts<'a, 'b>(&'a self, grid: &'a [Vec<char>]) -> Vec<Self> {
        let next_blizzards = next_blizzards(self.blizzards.clone(), grid);
        [(0, 1), (0, -1), (1, 0), (-1, 0), (0, 0)] // 0,0 is for waiting
            .into_iter()
            .filter_map(move |dxdy| {
                let next_pos = self.cur_pos.apply(dxdy)?;
                // TODO: should blizzards be a hashmap so we don't have to iterate the whole thing
                let collision = next_blizzards.iter().any(|(c, _)| *c == next_pos);
                if collision || grid.get(next_pos.y)?.get(next_pos.x) == Some(&'#') {
                    return None;
                }

                Some(State {
                    cur_pos: next_pos,
                    blizzards: next_blizzards.clone(),
                })
            })
            .collect()
    }
}

fn next_blizzards(mut blizzards: Vec<(Coord, char)>, grid: &[Vec<char>]) -> Vec<(Coord, char)> {
    for (coord, dir) in &mut blizzards {
        let (dx, dy) = match dir {
            '^' => (0, -1),
            'v' => (0, 1),
            '<' => (-1, 0),
            '>' => (1, 0),
            _ => panic!("Invalid direction"),
        };
        let c @ Coord { x, y } = coord.apply((dx, dy)).unwrap();
        let row = &grid[y];
        *coord = match row[x] {
            '.' => c,
            '#' => match dir {
                '^' | 'v' => Coord {
                    x,
                    y: if y == 0 { grid.len() - 2 } else { 1 },
                },
                '<' | '>' => Coord {
                    x: if x == 0 { row.len() - 2 } else { 1 },
                    y,
                },
                _ => unreachable!(),
            },
            otherwise => panic!("Invalid tile: {}", otherwise),
        };
    }
    blizzards
}

fn main() {
    let mut start = None;
    let mut end = None;

    let mut grid: Vec<Vec<char>> = vec![];
    let mut blizzards: Vec<(Coord, char)> = vec![];
    let input = INPUT;
    let lines_ct = input.lines().count();
    for (y, line) in input.lines().enumerate() {
        let mut row: Vec<char> = vec![];
        for (x, mut ch) in line.chars().enumerate() {
            match ch {
                '>' | '<' | '^' | 'v' => {
                    blizzards.push((Coord { x, y }, ch));
                    ch = '.';
                }
                '.' => {
                    if y == 0 {
                        start = Some(Coord { x, y });
                    }
                    if y == lines_ct - 1 {
                        end = Some(Coord { x, y });
                    }
                }
                '#' => (),
                _ => panic!("Invalid character: {}", ch),
            }
            row.push(ch);
        }
        grid.push(row);
    }
    let start = start.unwrap();
    let end = end.unwrap();
    let mut state = State {
        cur_pos: start,
        blizzards,
    };

    let path = [end, start, end];
    let mut total = 0;
    for (i, dest) in path.iter().enumerate() {
        let (mut path, cost) = astar(
            &state,
            |state| state.nexts(&grid).into_iter().map(move |s| (s, 1)),
            |s| s.cur_pos.dist(dest),
            |s| s.cur_pos == *dest,
        )
        .unwrap();
        total += cost;
        if i == 0 {
            println!("part 1: {}", total);
        }
        state = path.pop().unwrap();
    }
    println!("part 2: {}", total);
}

#[allow(unused)]
const SAMPLE: &str = "#.#####
#.....#
#>....#
#.....#
#...v.#
#.....#
#####.#";

#[allow(unused)]
const SAMPLE_COMPLEX: &str = "#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#";

const INPUT: &str = include_str!("../input.txt");
