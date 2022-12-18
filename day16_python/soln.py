from pprint import pprint as pp
from collections import namedtuple
from functools import cache, lru_cache
valves = {}
Valve = namedtuple('Valve', 'rate dests')

for line in open('input.txt').read().splitlines():
    words = line.split()
    src = words[1]
    rate = int(words[4].strip('rate=;'))
    dests = [w.strip(',') for w in words[9:]]
    valves[src] = Valve(rate, dests)

@cache
def part1(src, time_remaining, open_valves):
    if not time_remaining: return 0

    rate = sum(valves[valve].rate for valve in open_valves)

    this_valve = valves[src]
    nexts = []
    # 1. we could move to any of the dests, which takes 1 turn
    for dest in this_valve.dests:
        next = rate + part1(dest, time_remaining-1,
                                    open_valves)
        nexts.append(next)
    # 2. we could open this valve, if rate > 0
    if this_valve.rate > 0 and src not in open_valves:
        next = rate + part1(src, time_remaining-1,
                            tuple(sorted(set(open_valves+(src,)))))
        nexts.append(next)

    return max(nexts)

print('part 1:', part1('AA', 30, ()))

def part2(us_src, el_src, time_remaining, open_valves):
    if not time_remaining: return 0

    rate = sum(valves[valve].rate for valve in open_valves)

    our_valve = valves[us_src]
    el_valve = valves[el_src]
    nexts = []

    # 2. we could open this valve, if rate > 0
    if our_valve.rate > 0 and us_src not in open_valves:
        # 1. elph could move to any of the dests
        for eleph_dest in el_valve.dests:
            next = rate + part2(us_src, eleph_dest,
                                time_remaining-1, 
                                tuple(sorted(set((us_src,)+open_valves))))
            nexts.append(next)
        # 2. eleph could open valve
        if el_valve.rate > 0 and el_src not in open_valves and el_src != us_src:
            next = rate + part2(us_src, el_src,
                    time_remaining-1,
                    tuple(sorted(set(open_valves+(el_src,us_src)))))
            nexts.append(next)
    else:
        # 1. we could move to any of the dests, which takes 1 turn
        for us_dest in our_valve.dests:
            # 1. elph could move to any of the dests
            for eleph_dest in el_valve.dests:
                next = rate + part2(us_dest, eleph_dest,
                                    time_remaining-1, open_valves)
                nexts.append(next)
            # 2. eleph could open valve
            if el_valve.rate > 0 and el_src not in open_valves:
                next = rate + part2(us_dest, el_src, time_remaining-1,
                                    tuple(sorted(set(open_valves+(el_src,)))))
                nexts.append(next)


    return max(nexts)

print('part 2:', part2('AA', 'AA', 26, ()))
