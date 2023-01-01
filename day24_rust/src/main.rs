use std::iter::from_fn;

#[derive(Copy, Clone, Debug, PartialEq)]
struct Coord {
    x: usize,
    y: usize,
}

impl Coord {
    fn apply(self, dxdy: (isize, isize)) -> Self {
        Self {
            x: self.x.checked_add_signed(dxdy.0).unwrap(),
            y: self.y.checked_add_signed(dxdy.1).unwrap(),
        }
    }
}

#[derive(Clone, Debug)]
struct State {
    // our_pos: Coord,
    blizzards: Vec<(Coord, char)>,
}

impl State {
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
}

fn iter(grid: &[Vec<char>], mut state: State) -> impl Iterator<Item = State> + '_ {
    from_fn(move || {
        for (coord, dir) in &mut state.blizzards {
            let (dx, dy) = match dir {
                '^' => (0, -1),
                'v' => (0, 1),
                '<' => (-1, 0),
                '>' => (1, 0),
                _ => panic!("Invalid direction"),
            };
            let mut c @ Coord { x, y } = coord.apply((dx, dy));
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
        Some(state.clone())
    })
}

fn main() {
    let mut grid: Vec<Vec<char>> = vec![];
    let mut blizzards: Vec<(Coord, char)> = vec![];
    for (y, line) in SAMPLE_COMPLEX.lines().enumerate() {
        let mut row: Vec<char> = vec![];
        for (x, mut ch) in line.chars().enumerate() {
            match ch {
                '>' | '<' | '^' | 'v' => {
                    blizzards.push((Coord { x, y }, ch));
                    ch = '.';
                }
                '.' | '#' => (),
                _ => panic!("Invalid character: {}", ch),
            }
            row.push(ch);
        }
        grid.push(row);
    }
    let states = iter(&grid, State { blizzards });
    for (state, round) in states.take(18).zip(1..) {
        println!("----------------------------------------");
        println!("Round {}", round);
        println!("----------------------------------------");
        state.print(&grid);
        println!();
    }
}

const SAMPLE: &str = "#.#####
#.....#
#>....#
#.....#
#...v.#
#.....#
#####.#";

const SAMPLE_COMPLEX: &str = "#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#";
