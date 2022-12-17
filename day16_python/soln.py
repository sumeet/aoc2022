from pprint import pprint as pp
from collections import namedtuple
from functools import cache
valves = {}
Valve = namedtuple('Valve', 'rate dests')

for line in open('input.txt').read().splitlines():
    words = line.split()
    src = words[1]
    rate = int(words[4].strip('rate=;'))
    dests = [w.strip(',') for w in words[9:]]
    valves[src] = Valve(rate, dests)

@cache
def max_flow_rate(src, time_remaining, open_valves):
    if not time_remaining: return 0

    rate = sum(valves[valve].rate for valve in open_valves)

    this_valve = valves[src]
    nexts = []
    # 1. we could move to any of the dests, which takes 1 turn
    for dest in this_valve.dests:
        next = rate + max_flow_rate(dest, time_remaining-1,
                                    open_valves)
        nexts.append(next)
    # 2. we could open this valve, if rate > 0
    if this_valve.rate > 0:
        next = rate + max_flow_rate(src, time_remaining-1,
                    tuple(set(open_valves+(src,))))
        nexts.append(next)

    return max(nexts)


print('part 1:', max_flow_rate('AA', 30, ()))
