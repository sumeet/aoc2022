using Path = System.Collections.Generic.List<Coord>;
using Cave = System.Collections.Generic.Dictionary<Coord, char>;

var file = File.OpenText("input.txt");
List<Path> rockPaths = new List<Path>();
while (file.ReadLine() is { } line) {
    var path = from pathString in line.Split(" -> ")
        let coord = pathString.Split(",")
        select new Coord(int.Parse(coord[0]), int.Parse(coord[1]));
    rockPaths.Add(path.ToList());
}

var highestRockDepth = int.MinValue;
var cave = new Cave();
foreach (var rockPath in rockPaths) {
    for (var i = 0; i < rockPath.Count - 1; i++) {
        var (src, dst) = (rockPath[i], rockPath[i + 1]);
        if (src.X == dst.X)
            for (int y = Math.Min(src.Y, dst.Y); y <= Math.Max(src.Y, dst.Y); y++) {
                cave[new Coord(src.X, y)] = '#';
                highestRockDepth = Math.Max(highestRockDepth, y);
            }
        else if (src.Y == dst.Y)
            for (int x = Math.Min(src.X, dst.X); x <= Math.Max(src.X, dst.X); x++) {
                cave[new Coord(x, src.Y)] = '#';
                highestRockDepth = Math.Max(highestRockDepth, src.Y);
            }
        else throw new Exception("Path wasn't straight");
    }
}

var sandStartPoint = new Coord(500, 0);
var numSand = 0;
while (true) {
    var sand = sandStartPoint;
    Fall: foreach (var next in sand) {
        if (!cave.ContainsKey(next)) {
            sand = next;
            if (sand.Y > highestRockDepth) goto DonePart1;
            goto Fall;
        }
    }
    cave.Add(sand, 'o');
    numSand++;
}
DonePart1: Console.WriteLine("Part 1: " + numSand);

var floorY = highestRockDepth + 2;
while (!cave.ContainsKey(sandStartPoint)) {
    var sand = sandStartPoint;
    Fall: foreach (var next in sand) {
        if (!next.IsOccupied(cave, floorY)) {
            sand = next;
            goto Fall;
        }
    }
    cave.Add(sand, 'o');
    numSand++;
}
Console.WriteLine("Part 2: " + numSand);


struct Coord {
    public int X; public int Y;
    public Coord(int x, int y) { X = x; Y = y; }
    public override String ToString() { return X + "," + Y; }
    public Coord Down() { return new Coord(X, Y + 1); }
    public Coord DownLeft() { return new Coord(X - 1, Y + 1); }
    public Coord DownRight() { return new Coord(X + 1, Y + 1); }
    public IEnumerator<Coord> GetEnumerator() {
        yield return Down();
        yield return DownLeft();
        yield return DownRight();
    }
    public bool IsOccupied(Cave cave, int floorHeight) {
        return Y >= floorHeight || cave.ContainsKey(this);
    }
    public static void printGrid(Cave cave, int loX, int hiX, int loY, int hiY) {
        for (int y = loY; y <= hiY; y++) {
            for (int x = loX; x <= hiX; x++) {
                var coord = new Coord(x, y);
                if (cave.ContainsKey(coord)) Console.Write(cave[coord]);
                else Console.Write('.');
            }
            Console.WriteLine();
        }
    } 
}