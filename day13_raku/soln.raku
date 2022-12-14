# in raku, [[1]], is actually [1], similar to how you need
# a comma in python to make a single-element tuple
# $[$[1]] would actually give the nested list
sub parse($l) { $l.subst('[', '$[', :g).EVAL }
my @pairs = open('input.txt')
  .split("\n\n")
  .map: *.split("\n").head(2).map(&parse).Array;

multi sub cmp(Array $l, Int $r) { cmp($l, [$r]) }
multi sub cmp(Int $l, Array $r) { cmp([$l], $r) }
multi sub cmp(Array $l, Array $r) {
  for @($l) Z[&cmp] @($r) { when (1|-1) { return $_; } }
  cmp($l.elems, $r.elems)
}
multi sub cmp(Int $l, Int $r) { $l <=> $r }

my $sum = 0;
for 1..* Z @pairs -> ($i, $pair) {
  $sum += $i if cmp(|$pair) == -1;
}
say "part1: ", $sum;

my @dividers = [$[$[2]], $[$[6]]];
my @packets = [|@pairs.List.flat, |@dividers].sort: &cmp;
my $product = [*] @packets.kv.map: {
  $^i+1 if $^p (elem) @dividers;
};
say "part2: ", $product;
