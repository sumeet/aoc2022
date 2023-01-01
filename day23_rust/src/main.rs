#![feature(type_alias_impl_trait)]
#![feature(trait_alias)]
#![feature(box_syntax)]
#![feature(iter_advance_by)]

use std::collections::{HashMap, HashSet};
use std::iter::once;

fn main() {
    let mut elf_pts = INPUT
        .lines()
        .enumerate()
        .flat_map(|(y, line)| {
            line.chars().enumerate().filter_map(move |(x, c)| match c {
                '#' => Some(Point {
                    x: x as isize,
                    y: y as isize,
                }),
                _ => None,
            })
        })
        .collect::<HashSet<_>>();

    let mut move_orders = move_orders();
    let mut src_by_dest: HashMap<Point, Src> = HashMap::new();
    for round in 1.. {
        let this_move_orders = take::<_, 4>(&mut move_orders);
        move_orders.advance_by(1).unwrap();

        for &pt in &elf_pts {
            if all_empty(pt, &ALL_DIRS, &elf_pts) {
                continue;
            }

            'moves: for (dxdys, dest) in this_move_orders {
                let dest = pt.apply(dest);
                if all_empty(pt, &dxdys, &elf_pts) {
                    let src = src_by_dest.entry(dest).or_insert(Src::None);
                    *src = match src {
                        Src::None => Src::One(pt),
                        Src::One(_) => Src::Many,
                        Src::Many => Src::Many,
                    };
                    break 'moves;
                }
            }
        }
        let mut elf_has_moved = false;
        for (pt, src) in src_by_dest.drain() {
            if let Src::One(src) = src {
                elf_pts.remove(&src);
                elf_pts.insert(pt);
                elf_has_moved = true;
            }
        }

        const PART1_ROUND: usize = 10;
        if round == PART1_ROUND - 1 {
            dbg!(part1(&elf_pts));
        }

        if !elf_has_moved {
            let part2 = round;
            dbg!(part2);
            break;
        }
    }
}

fn part1(elf_pts: &HashSet<Point>) -> usize {
    let mut minx = isize::MAX;
    let mut maxx = isize::MIN;
    let mut miny = isize::MAX;
    let mut maxy = isize::MIN;
    for Point { x, y } in elf_pts {
        minx = minx.min(*x);
        maxx = maxx.max(*x);
        miny = miny.min(*y);
        maxy = maxy.max(*y);
    }
    let mut num_empties = 0;
    for y in miny..=maxy {
        for x in minx..=maxx {
            let pt = Point { x, y };
            if !elf_pts.contains(&pt) {
                num_empties += 1;
            }
        }
    }
    num_empties
}

fn all_empty(pt: Point, dxdys: &[Dxdy], elf_pts: &HashSet<Point>) -> bool {
    dxdys.iter().all(|&dxdy| !elf_pts.contains(&pt.apply(dxdy)))
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
    fn apply(self, dxdy: Dxdy) -> Self {
        Self {
            x: self.x + dxdy.0,
            y: self.y + dxdy.1,
        }
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

const INPUT: &str = include_str!("../input.txt");
