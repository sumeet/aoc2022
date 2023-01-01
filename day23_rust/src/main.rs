#![feature(type_alias_impl_trait)]
#![feature(trait_alias)]
#![feature(box_syntax)]
#![feature(iter_advance_by)]

use std::collections::{HashMap, HashSet};
use std::iter::once;

fn main() {
    let mut elf_pts = SAMPLE
        .lines()
        .enumerate()
        .flat_map(|(y, line)| {
            line.chars().enumerate().filter_map(|(x, c)| match c {
                '#' => Some(Point {
                    x: x as isize,
                    y: y as isize,
                }),
                _ => None,
            })
        })
        .collect::<HashSet<_>>();

    let mut move_orders = move_orders();
    let src_by_dest_init: HashMap<Point, Src> = HashMap::new();
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
        for &pt @ Point { x, y } in &elf_pts {
            println!("elf at ({},{}): ", x, y);
            if all_empty(pt, &ALL_DIRS, &elf_pts) {
                continue;
            }

            'moves: for (dxdys, dest) in this_move_orders {
                println!("  trying to move {}", s(dest));
                let dest = pt.apply(dest);
                if dest.is_none() {
                    continue 'moves;
                }
                let dest = dest.unwrap();
                if all_empty(pt, &dxdys, &elf_pts) {
                    let src = src_by_dest.entry(dest).or_insert(Src::None);
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
        for (pt, src) in src_by_dest.iter() {
            if let Src::One(src) = src {
                elf_pts.remove(src);
                elf_pts.insert(*pt);
            }
        }
        println!();
        print_grid(&elf_pts);
        println!();
    }
}

fn print_grid(elf_pts: &HashSet<Point>) {
    let mut minx = isize::MAX;
    let mut maxx = isize::MIN;
    let mut miny = isize::MAX;
    let mut maxy = isize::MIN;
}

fn all_empty(pt: Point, dxdys: &[Dxdy], elf_pts: &HashSet<Point>) -> bool {
    dxdys.iter().all(|&dxdy| {
        pt.apply(dxdy)
            .map(|pt| !elf_pts.contains(&pt))
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

#[derive(Copy, Clone, PartialEq, Eq, Hash)]
struct Point {
    x: isize,
    y: isize,
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
