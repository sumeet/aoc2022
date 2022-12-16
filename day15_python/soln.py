from collections import namedtuple
Point = namedtuple('Point', 'x y')

FILENAME = 'input.txt'
Y_TO_CHECK_PART1 = 2000000
MAX_COORD_VAL_PART2 = 4_000_000

def brange(lo, hi):
    lo = max(0, lo)
    hi = min(hi, MAX_COORD_VAL_PART2)
    return range(lo, hi)

class Sensor(namedtuple('Sensor', 'point dist_to_beacon')):
    @property
    def x(self):
        return self.point.x
    @property
    def y(self):
        return self.point.y
    def excludes(self, other_point):
        dist = manhattan(self.point, other_point)
        return dist <= self.dist_to_beacon
    @property
    def points_at_edges(self):
        d = self.dist_to_beacon + 1
        for x in brange(self.x - d, self.x + d+1):
            dy = abs(d - abs(self.x - x))
            if self.y+dy<=MAX_COORD_VAL_PART2:
                yield Point(x, self.y+dy)
            if self.y-dy>=0:
                yield Point(x, self.y-dy)


def manhattan(p1, p2):
    return abs(p1.x - p2.x) + abs(p1.y - p2.y)

def try_parse(w):
    try:
        return int(w.strip('x=,y:'))
    except ValueError:
        return None

def all_excluded_xs(sensor, less_than_manhattan):
    lo_exclusive = abs(sensor.y - Y_TO_CHECK_PART1) - less_than_manhattan + sensor.x
    hi_exclusive = -abs(sensor.y - Y_TO_CHECK_PART1) + less_than_manhattan + sensor.x
    return set(range(lo_exclusive, hi_exclusive+1))

excluded_poss = set()

beacons = []
sensors = []

lines = open(FILENAME).read().splitlines()
for line in lines:
    parsed = map(try_parse, line.split())
    (x, y, bx, by) = filter(lambda x: x is not None,
                            parsed)
    sensor = Point(x, y)
    beacon = Point(bx, by)
    beacons.append(beacon)
    dist = manhattan(sensor, beacon)
    sensors.append(Sensor(sensor, dist))
    excluded_poss |= all_excluded_xs(sensor, dist)

for beacon in beacons:
    if beacon.y == Y_TO_CHECK_PART1:
        try:
            excluded_poss.remove(beacon.x)
        except KeyError:
            pass

print('part 1:', len(excluded_poss))

for sensor in sensors:
    for point in sensor.points_at_edges:
        if not any(sensor.excludes(point) for sensor in sensors):
            tuning_freq = lambda p: p.x * 4000000 + p.y
            print('part 2:', tuning_freq(point))
            exit(0)
