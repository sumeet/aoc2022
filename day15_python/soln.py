if True:
    FILENAME = 'sample.txt'
    Y_TO_CHECK_PART1 = 10
    MAX_COORD_VAL_PART2 = 20
else:
    FILENAME = 'input.txt'
    Y_TO_CHECK_PART1 = 2000000
    MAX_COORD_VAL_PART2 = 4_000_000

from collections import namedtuple
Point = namedtuple('Point', 'x y')

class Sensor(namedtuple('Sensor', 'point dist_to_beacon')):
    def excludes(self, other_point):
        dist = manhattan(self.point, other_point)
        return dist <= self.dist_to_beacon

    @property
    def min_x_seen(self):
        return max(0,
                self.point.x - self.dist_to_beacon)

    @property
    def max_x_seen(self):
        return min(MAX_COORD_VAL_PART2,
                self.point.x + self.dist_to_beacon)

    @property
    def min_y_seen(self):
        return max(0,
                self.point.y - self.dist_to_beacon)

    @property
    def max_y_seen(self):
        return min(MAX_COORD_VAL_PART2,
                self.point.y + self.dist_to_beacon)


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
tuning_freq = lambda p: p.x * 4000000 + p.y

def all_points():
    for x in range(0, MAX_COORD_VAL_PART2):
        for y in range(0, MAX_COORD_VAL_PART2):
            yield Point(x, y)

for point in all_points():
    if not any(sensor.excludes(point) for sensor in sensors):
        print(point)
        print(tuning_freq(point))

max_min_x = float('inf')
min_max_x = float('-inf')

max_min_y = float('inf')
min_max_y = float('-inf')
for sensor in sensors:
    max_min_x = min(max_min_x, sensor.min_x_seen)
    min_max_x = max(min_max_x, sensor.max_x_seen)
    max_min_y = min(max_min_y, sensor.min_y_seen)
    min_max_y = max(min_max_y, sensor.max_y_seen)

print(f'max_min_x: {max_min_x}')
print(f'min_max_x: {min_max_x}')
print(f'max_min_y: {max_min_y}')
print(f'min_max_y: {min_max_y}')
