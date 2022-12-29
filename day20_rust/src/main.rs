use std::collections::{HashMap, HashSet};

type FileEntry = (usize, isize);

fn main() {
    let orig_file = INPUT
        .trim()
        .split("\n")
        .map(|s| s.parse().unwrap())
        .enumerate()
        .collect::<Vec<FileEntry>>();
    let idx_by_value = orig_file
        .iter()
        .enumerate()
        .map(|(i, v)| (*v, i))
        .collect::<HashMap<_, _>>();
    let mut nodes = Node::from_vals(&orig_file);
    let mut zero_val = None;
    for val in &orig_file {
        if val.1 == 0 {
            zero_val = Some(val);
        }
        move_node(&idx_by_value, &mut nodes, *val);
    }
    // verify_nodes(&nodes);
    print(&nodes);
    print_b(&nodes);
    let sum = [1000, 2000, 3000]
        .iter()
        .map(|i| dbg!(nth_from(*i, *zero_val.unwrap(), &idx_by_value, &nodes)).1)
        .sum::<isize>();
    dbg!(sum);
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

fn verify_nodes(nodes: &[Node]) {
    for node in nodes {
        assert_eq!(node.val, nodes[nodes[node.next_idx].prev_idx].val);
        assert_eq!(node.val, nodes[nodes[node.prev_idx].next_idx].val);
    }
    // also verify no repeats
    // let mut seen = HashSet::new();
    // let mut loc = 0;
    // for _ in 0..nodes.len() {
    //     seen.insert(nodes[loc].val);
    //     loc = nodes[loc].next_idx;
    // }
    // assert_eq!(seen.len(), nodes.len());
}

fn print(nodes: &[Node]) {
    let mut idx = 0;
    print!("[");
    for _ in 0..nodes.len() + 5 {
        print!("{}, ", nodes[idx].val.1);
        idx = nodes[idx].next_idx;
    }
    println!("]");
}

fn print_b(nodes: &[Node]) {
    let mut idx = 0;
    print!("b[");
    for _ in 0..nodes.len() * 2 {
        print!("{}, ", nodes[idx].val.1);
        idx = nodes[idx].prev_idx;
    }
    println!("]");
}

fn move_node(idx_by_value: &HashMap<FileEntry, usize>, nodes: &mut [Node], value: FileEntry) {
    if value.1 == 0 {
        return;
    }
    let orig_idx = idx_by_value[&value];

    // first cut out the node
    let node = nodes[orig_idx];
    nodes[node.prev_idx].next_idx = node.next_idx;
    nodes[node.next_idx].prev_idx = node.prev_idx;

    let value = value.1;
    if value > 0 {
        let mut idx = orig_idx;
        for _ in 0..(value) {
            idx = nodes[idx].next_idx;
        }
        let new_prev_index = idx;
        let new_next_index = nodes[idx].next_idx;
        nodes[new_prev_index].next_idx = orig_idx;
        nodes[new_next_index].prev_idx = orig_idx;
        nodes[orig_idx].prev_idx = new_prev_index;
        nodes[orig_idx].next_idx = new_next_index;
    } else if value < 0 {
        let mut idx = orig_idx;
        for _ in 0..value.abs() {
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

const SAMPLE: &str = "1
2
-3
3
-2
0
4";

const INPUT: &str = include_str!("../input.txt");
const INPUT_ALT: &str = include_str!("../input-alt.txt");
