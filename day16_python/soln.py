from pprint import pprint as pp
from collections import namedtuple
from functools import cache, lru_cache
valves = {}
Valve = namedtuple('Valve', 'rate dests')

valve_index = 0
valve_num_by_id = {}
def valve_num(valve_id):
    global valve_index

    if valve_id in valve_num_by_id:
        return valve_num_by_id[valve_id]
    valve_num_by_id[valve_id] = valve_index
    valve_index += 1
    return valve_num_by_id[valve_id]

for line in open('input.txt').read().splitlines():
    words = line.split()
    src = valve_num(words[1])
    rate = int(words[4].strip('rate=;'))
    dests = list(map(valve_num, (w.strip(',') for w in words[9:])))
    valves[src] = Valve(rate, dests)

@cache
def part1(src, time_remaining, open_valves):
    if not time_remaining: return 0

    rate = sum(valves[valve].rate for valve in open_valves)

    this_valve = valves[src]
    nexts = []
    # 1. we could move to any of the dests, which takes 1 turn
    for dest in this_valve.dests:
        next = rate + part1(dest, time_remaining-1, open_valves)
        nexts.append(next)
    # 2. we could open this valve, if rate > 0
    if this_valve.rate > 0 and src not in open_valves:
        next = rate + part1(src, time_remaining-1,
                            tuple(sorted(set(open_valves+(src,)))))
        nexts.append(next)

    return max(nexts)

print('part 1:', part1(valve_num('AA'), 30, ()))

def customcache(part2_func):
    cache = {}
    def new_part2_func(us_src, el_src, time_remaining, open_valves, us_parent, el_parent):
        key = us_src, el_src, time_remaining, open_valves
        if key in cache:
            return cache[key]
        res = part2_func(us_src, el_src, time_remaining, open_valves, us_parent, el_parent)
        cache[key] = res
        return res
    return new_part2_func

@customcache
def part2(us_src, el_src, time_remaining, open_valves, us_parent, el_parent):
    if not time_remaining: return 0

    rate = sum(valves[valve].rate for valve in open_valves)

    our_valve = valves[us_src]
    el_valve = valves[el_src]
    nexts = []

    # 2. we could open this valve, if rate > 0
    if our_valve.rate > 0 and us_src not in open_valves:
        # 1. elph could move to any of the dests
        for eleph_dest in el_valve.dests:
            if el_parent == eleph_dest:
                continue

            next = rate + part2(us_src, eleph_dest,
                                time_remaining-1, 
                                tuple(sorted(set((us_src,)+open_valves,
                                    ))), us_src, el_src)
            nexts.append(next)
        # 2. eleph could open valve
        if el_valve.rate > 0 and el_src not in open_valves and el_src != us_src:
            next = rate + part2(us_src, el_src,
                    time_remaining-1,
                    tuple(sorted(set(open_valves+(el_src,us_src)))),
                    us_src, el_src)
            nexts.append(next)
    else:
        # 1. we could move to any of the dests, which takes 1 turn
        for us_dest in our_valve.dests:
            if us_dest == us_parent: continue

            # 1. elph could move to any of the dests
            for eleph_dest in el_valve.dests:
                if eleph_dest == el_parent: continue
                next = rate + part2(us_dest, eleph_dest,
                                    time_remaining-1, open_valves, us_src, el_src)
                nexts.append(next)
            # 2. eleph could open valve
            if el_valve.rate > 0 and el_src not in open_valves:
                next = rate + part2(us_dest, el_src, time_remaining-1,
                                    tuple(sorted(set(open_valves+(el_src,)))), us_src, el_src)
                nexts.append(next)


    if not nexts:
        nexts = [0]
    return max(nexts)

print('part 2:', part2(valve_num('AA'), valve_num('AA'), 26, (), None, None))
