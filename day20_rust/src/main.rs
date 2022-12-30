use std::collections::HashMap;

type FileEntry = (usize, isize);

fn main() {
    let mut orig_file = INPUT
        .trim()
        .split("\n")
        .map(|s| s.parse().unwrap())
        .enumerate()
        .collect::<Vec<FileEntry>>();
    println!("part 1: {}", solve_n(&mut orig_file.clone(), 1));

    const DECRYPT_KEY: isize = 811589153;
    const NUM_MIXES: usize = 10;
    orig_file.iter_mut().for_each(|(_, v)| *v *= DECRYPT_KEY);
    println!("part 2: {}", solve_n(&mut orig_file, NUM_MIXES));
}

fn solve_n(orig_entries: &[FileEntry], num_mixes: usize) -> isize {
    let idx_by_value = orig_entries
        .iter()
        .enumerate()
        .map(|(i, v)| (*v, i))
        .collect::<HashMap<_, _>>();
    let mut nodes = Node::from_vals(orig_entries);
    let mut zero_val = None;
    for _ in 0..num_mixes {
        for val in orig_entries.iter() {
            if val.1 == 0 {
                zero_val = Some(val);
            }
            move_node(&idx_by_value, &mut nodes, *val);
        }
    }

    [1000, 2000, 3000]
        .iter()
        .map(|i| nth_from(*i, *zero_val.unwrap(), &idx_by_value, &nodes).1)
        .sum()
}

fn nth_from(
    n: usize,
    from: FileEntry,
    idx_by_value: &HashMap<FileEntry, Idx>,
    nodes: &[Node],
) -> FileEntry {
    let mut loc = idx_by_value[&from];
    for _ in 0..(n % nodes.len()) {
        loc = nodes[loc].next_idx;
    }
    nodes[loc].val
}

fn move_node(idx_by_value: &HashMap<FileEntry, usize>, nodes: &mut [Node], value: FileEntry) {
    let computed = value.1 % (nodes.len() as isize - 1);
    if computed == 0 {
        return;
    }
    let orig_idx = idx_by_value[&value];

    // first cut out the node
    let node = nodes[orig_idx];
    nodes[node.prev_idx].next_idx = node.next_idx;
    nodes[node.next_idx].prev_idx = node.prev_idx;

    if computed > 0 {
        let mut idx = orig_idx;
        for _ in 0..computed {
            idx = nodes[idx].next_idx;
        }
        let new_prev_index = idx;
        let new_next_index = nodes[idx].next_idx;
        nodes[new_prev_index].next_idx = orig_idx;
        nodes[new_next_index].prev_idx = orig_idx;
        nodes[orig_idx].prev_idx = new_prev_index;
        nodes[orig_idx].next_idx = new_next_index;
    } else if computed < 0 {
        let mut idx = orig_idx;
        for _ in 0..computed.abs() {
            idx = nodes[idx].prev_idx;
        }
        let new_prev_index = nodes[idx].prev_idx;
        let new_next_index = idx;
        nodes[new_prev_index].next_idx = orig_idx;
        nodes[new_next_index].prev_idx = orig_idx;
        nodes[orig_idx].prev_idx = new_prev_index;
        nodes[orig_idx].next_idx = new_next_index;
    }
}

type Idx = usize;

#[derive(Debug, Copy, Clone)]
struct Node {
    val: (usize, isize),
    prev_idx: Idx,
    next_idx: Idx,
}

impl Node {
    fn from_vals(vals: &[FileEntry]) -> Vec<Self> {
        let mut nodes = Vec::with_capacity(vals.len());
        let (first, rest) = vals.split_first().unwrap();
        nodes.push(Node {
            val: *first,
            prev_idx: vals.len() - 1,
            next_idx: 1,
        });
        let (last, rest) = rest.split_last().unwrap();
        for (i, val) in rest.iter().enumerate() {
            nodes.push(Node {
                val: *val,
                prev_idx: i,
                next_idx: i + 2,
            });
        }
        nodes.push(Node {
            val: *last,
            prev_idx: vals.len() - 2,
            next_idx: 0,
        });
        nodes
    }
}

#[allow(unused)]
const SAMPLE: &str = "1
2
-3
3
-2
0
4";

#[allow(unused)]
const INPUT: &str = include_str!("../input.txt");
