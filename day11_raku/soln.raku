use v6;

my $file = open 'sample.txt';
my @monkeys;

my %current_monkey;
for $file.lines.map(*.trim) -> $line {
  if $line.starts-with("Monkey") {
    %current_monkey = ();
  } elsif $line.starts-with("Starting items:") {
    my $items = $line.split(": ")[1];
    $items = $items.split(", ").map({ +$_ });
    %current_monkey{'items'} = $items;
  } elsif $line.starts-with("Operation:") {
    my $op = $line.split(": ")[1];
    $op = $op.split(" = ")[1];
    %current_monkey{'op'} = $op;
  } elsif $line.starts-with("Test:") {
  } elsif !$line {
    @monkeys.append: %current_monkey;
  } else {
    die "unexpected line: " ~ $line;
  }

}

say @monkeys;
