from pprint import pprint as pp
from heapq import heapify, heappush, heappop
from collections import namedtuple, defaultdict
from functools import cache, lru_cache
valves = {}
Valve = namedtuple('Valve', 'rate dests')

for line in open('sample.txt').read().splitlines():
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

class Qitem(namedtuple('Qitem',
    'rate us_src el_src time_remaining open_valves')):
    #def __lt__(self, other):
    #    return ((self.rate / max(self.time_remaining,1))
    #               >
    #            (other.rate / max(other.time_remaining,1)))

    @property
    def rate_from_open_valves(self):
        return sum(valves[valve].rate for valve in self.open_valves)

    @property
    def to_cache(self):
        return self._replace(open_valves=tuple(sorted(self.open_valves)))


        

start_qitem = Qitem(rate=0, us_src='AA', el_src='AA', time_remaining=26,
                    open_valves=set())
q = [start_qitem]
seen = set()
max_by_open_valves = defaultdict(lambda: float('-inf'))

def next_q_append(qitem):
    if (qitemcache := qitem.to_cache) in seen:
        return
    else:
        seen.add(qitemcache)
        next_q.append(qitem)

#def next_q_append(qitem):
#    key = (len(qitem.open_valves), time_remaining)
#    if max_by_open_valves[key] < qitem.rate:
#        max_by_open_valves[key] = qitem.rate
#        next_q.append(qitem)

next_q = []
max_rate = 0


while q:
    next_q.clear()
    print(f'q length: {len(q)}')
    for qitem in q:
        (cur_rate, us_src, el_src, time_remaining, open_valves) = qitem

        if not time_remaining:
            old_max_rate = max_rate
            max_rate = max(cur_rate, max_rate)
            if max_rate > old_max_rate:
                print(f'max rate changed to {max_rate}')
            continue

        rate = sum(valves[valve].rate for valve in open_valves) + cur_rate

        our_valve = valves[us_src]
        el_valve = valves[el_src]

        # 2. we could open this valve, if rate > 0
        if our_valve.rate > 0 and us_src not in open_valves:
            # 1. elph could move to any of the dests
            for eleph_dest in el_valve.dests:

                next_q_append(Qitem(rate, us_src, eleph_dest,
                                  time_remaining-1,
                                  set([us_src])|open_valves))
            # 2. eleph could open valve
            if el_valve.rate > 0 and el_src not in open_valves and el_src != us_src:
                next_q_append(Qitem(rate, us_src, el_src,
                                  time_remaining-1,
                                  open_valves|set([el_src,us_src])))
        else:
            # 1. we could move to any of the dests, which takes 1 turn
            for us_dest in our_valve.dests:
                # 1. elph could move to any of the dests
                for eleph_dest in el_valve.dests:
                    next_q_append(Qitem(rate, us_dest, eleph_dest,
                                      time_remaining-1, open_valves))
                # 2. eleph could open valve
                if el_valve.rate > 0 and el_src not in open_valves:
                    next_q_append(Qitem(rate, us_dest, el_src, time_remaining-1,
                                      open_valves|set([el_src])))
    q, next_q = next_q, q


print('part 2:', max_rate)
