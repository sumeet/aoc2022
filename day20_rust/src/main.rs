use std::collections::VecDeque;

fn main() {
    let orig_file : VecDeque<isize> = SAMPLE.split("\n").map(|s| s.parse().unwrap()).collect();
    let mixed = mix_file(orig_file);
    // dbg!(mixed);
}

// supposed to be doing:
// 1, -3, 2, 3, -2, 0, 4 // start
// -3, 1, 2, 3, -2, 0, 4 // 1 move
// 1, 2, 3, -2, 0, 4, -3 // 2 moves
// 1, 2, 3, -2, 0, -3, 4 // 3 moves

fn mix_file(mut file: VecDeque<isize>) -> VecDeque<isize> {
    let orig_file = file.clone();
    let mut indexes = IndexLookup::new(&file);
    for val in orig_file {
        println!("{} is moving", val);

        let mut index = indexes.get(val);
        println!("{} is currently at index {}", val, index);

        // depending on if val is positive or negative, keep swapping that
        // index in file to the right or left, `val` number of times
        let len = file.len();
        if val > 0 {
            for _ in 0..val {
                let next_index = (index + 1) % len;
                file.swap(index, next_index);
                indexes.swap(file[index], file[next_index]);
                index = next_index;
            }
        } else if val < 0 {
            for _ in 0..val.abs() {
                let prev_index = index - 1;
                file.swap(index, prev_index);
                indexes.swap(file[index], file[prev_index]);
                index = prev_index;
                if index == 0 {
                    let popped = file.pop_front().unwrap();
                    file.push_back(popped);
                    for (i, val) in file.iter().enumerate() {
                        indexes.set(*val, i);
                    }
                    index = len - 1;
                }
            }
        }
        dbg!(&file);
        indexes.print();
    }
    file
}

fn minmax(v: &VecDeque<isize>) -> (isize, isize) {
    let mut min = v[0];
    let mut max = v[0];
    for i in 1..v.len() {
        if v[i] < min {
            min = v[i];
        }
        if v[i] > max {
            max = v[i];
        }
    }
    (min, max)
}

#[derive(Debug)]
struct IndexLookup {
    min: isize,
    max: isize,
    vec: Vec<Option<usize>>,
}


impl IndexLookup {
    fn new(file: &VecDeque<isize>) -> Self {
        let (min, max) = minmax(&file);
        let range = max - min + 1;
        let mut lookup = IndexLookup {
            min,
            max,
            vec: vec![None; range as usize],
        };

        for (i, v) in file.iter().enumerate() {
            lookup.set(*v, i);
        }

        lookup
    }

    fn set(&mut self, val: isize, index: usize) {
        self.vec[(val - self.min) as usize] = Some(index);
    }

    fn get(&self, val: isize) -> usize {
        self.vec[(val - self.min) as usize].unwrap()
    }

    fn swap(&mut self, val1: isize, val2: isize) {
        self.vec.swap((val1 - self.min) as usize, (val2 - self.min) as usize);
    }

    fn print(&self) {
        for (v, i) in self.vec.iter().enumerate() {
            if let Some(i) = i {
                print!("{}: {:?}, ", (v as isize + self.min), i);
            }
        }
        println!();
    }
}


const SAMPLE : &str = "1
2
-3
3
-2
0
4";