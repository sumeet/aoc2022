use pathfinding::prelude::astar;
use std::collections::{BTreeMap, HashMap};

#[derive(Copy, Clone, Debug, PartialEq, Eq, Hash, PartialOrd, Ord)]
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

type Blizzards = BTreeMap<Coord, Vec<char>>;

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
struct State {
    cur_pos: Coord,
    blizzards: Blizzards,
}

impl State {
    #[allow(unused)]
    fn print(&self, grid: &[Vec<char>]) {
        for (y, row) in grid.iter().enumerate() {
            for (x, c) in row.iter().enumerate() {
                let coord = Coord { x, y };
                if let Some(c) = self.blizzards.get(&coord) {
                    print!(
                        "{}",
                        if c.len() > 1 {
                            format!("{}", c.len())
                        } else {
                            format!("{}", c[0])
                        }
                    );
                } else {
                    print!("{}", c);
                }
            }
            println!();
        }
    }

    fn nexts<'a, 'b>(&'a self, grid: &'a [Vec<char>]) -> Vec<Self> {
        let next_blizzards = next_blizzards(&self.blizzards, grid);
        [(0, 1), (0, -1), (1, 0), (-1, 0), (0, 0)] // 0,0 is for waiting
            .into_iter()
            .filter_map(move |dxdy| {
                let next_pos = self.cur_pos.apply(dxdy)?;
                // TODO: should blizzards be a hashmap so we don't have to iterate the whole thing
                let collision = next_blizzards.iter().any(|(c, _)| *c == next_pos);
                if collision || grid[next_pos.y][next_pos.x] == '#' {
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

fn next_blizzards(blizzards: &Blizzards, grid: &[Vec<char>]) -> Blizzards {
    let mut next_blizzards = Blizzards::new();
    for (coord, dirs) in blizzards.iter() {
        for dir in dirs {
            let (dx, dy) = match dir {
                '^' => (0, -1),
                'v' => (0, 1),
                '<' => (-1, 0),
                '>' => (1, 0),
                _ => panic!("Invalid direction"),
            };
            let c @ Coord { x, y } = coord.apply((dx, dy)).unwrap();
            let row = &grid[y];
            let next_coord = match row[x] {
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
            next_blizzards.entry(next_coord).or_default().push(*dir);
        }
    }
    next_blizzards
}

fn main() {
    let mut start = None;
    let mut end = None;

    let mut grid: Vec<Vec<char>> = vec![];
    let mut blizzards = Blizzards::new();
    let input = INPUT;
    let lines_ct = input.lines().count();
    for (y, line) in input.lines().enumerate() {
        let mut row: Vec<char> = vec![];
        for (x, mut ch) in line.chars().enumerate() {
            match ch {
                '>' | '<' | '^' | 'v' => {
                    blizzards.entry(Coord { x, y }).or_default().push(ch);
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
    let begin = State {
        cur_pos: start,
        blizzards,
    };
    let (_, part1) = astar(
        &begin,
        // successors
        |state| state.nexts(&grid).into_iter().map(move |s| (s, 1)),
        // distance from end
        |state| state.cur_pos.dist(&end),
        // goal?
        |state| state.cur_pos == end,
    )
    .unwrap();
    dbg!(part1);
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
