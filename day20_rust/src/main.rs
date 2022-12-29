use std::collections::{HashMap, VecDeque};

fn main() {
    let orig_file = SAMPLE
        .trim()
        .split("\n")
        .map(|s| s.parse().unwrap())
        .collect::<Vec<isize>>();
    let idx_by_value = orig_file
        .iter()
        .enumerate()
        .map(|(i, v)| (*v, i))
        .collect::<HashMap<_, _>>();
    let mut nodes = Node::from_vals(&orig_file);
    print(&nodes);
    move_node(&idx_by_value, &mut nodes, 1);
    print(&nodes);
}

fn print(nodes: &[Node]) {
    let mut idx = 0;
    print!("[");
    for _ in 0..nodes.len() {
        print!("{}, ", nodes[idx].val);
        idx = nodes[idx].next_idx;
    }
    println!("]");
}

fn move_node(idx_by_value: &HashMap<isize, usize>, nodes: &mut [Node], value: isize) {
    let orig_idx = idx_by_value[&value];

    // first cut out the node
    let node = nodes[orig_idx];
    nodes[node.prev_idx].next_idx = node.next_idx;
    nodes[node.next_idx].prev_idx = node.prev_idx;

    if node.val > 0 {
        let mut idx = orig_idx;
        for _ in 0..node.val {
            println!("how many times");
            idx = nodes[idx].next_idx;
        }
        let new_prev_index = idx;
        let new_next_index = nodes[idx].next_idx;
        nodes[new_prev_index].next_idx = orig_idx;
        nodes[new_next_index].prev_idx = orig_idx;
        nodes[orig_idx].prev_idx = new_prev_index;
        nodes[orig_idx].next_idx = new_next_index;
    } else if node.val < 0 {
    }
}

type Idx = usize;

#[derive(Debug, Copy, Clone)]
struct Node {
    val: isize,
    prev_idx: Idx,
    next_idx: Idx,
}

impl Node {
    fn from_vals(vals: &[isize]) -> Vec<Self> {
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
