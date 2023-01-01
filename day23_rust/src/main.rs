#![feature(type_alias_impl_trait)]
#![feature(trait_alias)]
#![feature(box_syntax)]
#![feature(iter_advance_by)]

use std::iter::once;

fn main() {
    let mut rows: Vec<Vec<char>> = SAMPLE.lines().map(|line| line.chars().collect()).collect();
    let mut move_orders = move_orders();
    let src_by_dest_init: Vec<Vec<Src>> =
        rows.iter().map(|row| vec![Src::None; row.len()]).collect();
    const NUM_ROUNDS: usize = 10;
    for round in 0..NUM_ROUNDS {
        let this_move_orders = take::<_, 4>(&mut move_orders);
        println!("-----------------------------------");
        println!(
            "Round {}, first direction: {}",
            round + 1,
            s(this_move_orders[0].1),
        );
        println!("-----------------------------------");
        print_move_orders(&this_move_orders);
        move_orders.advance_by(1).unwrap();

        let mut src_by_dest = src_by_dest_init.clone();
        for (y, row) in rows.iter().enumerate() {
            for (x, &ch) in row.iter().enumerate() {
                if ch != '#' {
                    continue;
                }
                println!("elf at ({},{}): ", x, y);
                let pt = Point { x, y };
                if all_empty(pt, &ALL_DIRS, &rows) {
                    continue;
                }

                'moves: for (dxdys, dest) in this_move_orders {
                    println!("  trying to move {}", s(dest));
                    let dest = pt.apply(dest);
                    if dest.is_none()
                        || rows
                            .get(dest.unwrap().y)
                            .and_then(|row| row.get(dest.unwrap().x))
                            .is_none()
                    {
                        continue 'moves;
                    }
                    let dest = dest.unwrap();
                    if all_empty(pt, &dxdys, &rows) {
                        let src = &mut src_by_dest[dest.y][dest.x];
                        *src = match src {
                            Src::None => Src::One(pt),
                            Src::One(_) => Src::Many,
                            Src::Many => Src::Many,
                        };
                        println!("  moved to ({},{})", dest.x, dest.y);
                        break 'moves;
                    }
                }
            }
        }
        for (y, row) in src_by_dest.iter().enumerate() {
            for (x, &src) in row.iter().enumerate() {
                if let Src::One(src) = src {
                    rows[src.y][src.x] = '.';
                    rows[y][x] = '#';
                }
            }
        }
        println!();
        for row in &rows {
            println!("{}", row.iter().collect::<String>());
        }
        println!();
    }
}

fn all_empty(pt: Point, dxdys: &[Dxdy], rows: &[Vec<char>]) -> bool {
    dxdys.iter().all(|&dxdy| {
        pt.apply(dxdy)
            .map(|pt| matches!(g(&rows, pt), Some('.') | None))
            .unwrap_or(true)
    })
}

fn print_move_orders(move_orders: &[([Dxdy; 3], Dxdy); 4]) {
    for (checks, dest) in move_orders {
        println!(
            "Checks: {:?}, dest: {:?}",
            checks.iter().map(|&dxdy| s(dxdy)).collect::<Vec<_>>(),
            s(*dest),
        );
    }
}

#[derive(Copy, Clone)]
enum Src {
    None,
    One(Point),
    Many,
}

#[derive(Copy, Clone)]
struct Point {
    x: usize,
    y: usize,
}

impl Point {
    fn apply(self, dxdy: Dxdy) -> Option<Self> {
        Some(Self {
            x: self.x.checked_add_signed(dxdy.0)?,
            y: self.y.checked_add_signed(dxdy.1)?,
        })
    }
}

fn take<T, const N: usize>(it: &mut impl Iterator<Item = T>) -> [T; N] {
    #![allow(deprecated)]
    let mut arr: [T; N] = unsafe { std::mem::uninitialized() };
    for item in arr.iter_mut() {
        unsafe { std::ptr::write(item, it.next().unwrap()) }
    }
    arr
}

fn g(rows: &[Vec<char>], p: Point) -> Option<char> {
    rows.get(p.y)?.get(p.x).copied()
}

fn move_orders() -> impl Iterator<Item = ([Dxdy; 3], Dxdy)> {
    once(([N, NE, NW], N))
        .chain(once(([S, SE, SW], S)))
        .chain(once(([W, NW, SW], W)))
        .chain(once(([E, NE, SE], E)))
        .cycle()
}

type Dxdy = (isize, isize);

const N: Dxdy = (0, -1);
const NE: Dxdy = (1, -1);
const NW: Dxdy = (-1, -1);
const S: Dxdy = (0, 1);
const SE: Dxdy = (1, 1);
const SW: Dxdy = (-1, 1);
const W: Dxdy = (-1, 0);
const E: Dxdy = (1, 0);

const ALL_DIRS: [Dxdy; 8] = [N, NE, NW, S, SE, SW, W, E];

fn s(dxdy: Dxdy) -> String {
    match dxdy {
        N => format!("N"),
        NE => format!("NE"),
        NW => format!("NW"),
        S => format!("S"),
        SE => format!("SE"),
        SW => format!("SW"),
        W => format!("W"),
        E => format!("E"),
        _ => unreachable!(),
    }
}

const SAMPLE: &str = "..............
..............
.......#......
.....###.#....
...#...#.#....
....#...##....
...#.###......
...##.#.##....
....#..#......
..............
..............
..............";

const SAMPLE_SMALL: &str = ".....
..##.
..#..
.....
..##.
.....";
