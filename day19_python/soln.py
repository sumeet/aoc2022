from pprint import pprint as pp
costs = {'ore': {'ore': 4},
         'clay': {'ore': 2},
         'obs': {'ore': 4, 'clay': 14},
         'geode': {'ore': 2, 'obs': 7}}

def time_needed_for(robots, material, amt):
    pass

def maximize(material, num_turns_remaining):
    robots = {'ore': 1, 'clay': 0, 'obs': 0, 'geode': 0}
    mats = {'ore': 0, 'clay': 0, 'obs': 0, 'geode': 0}
    mats_needed = {mat: max(0, amt - mats[mat]) for (mat, amt) in costs[material].items()}
    pp(mats_needed)

maximize('geode', 24)
