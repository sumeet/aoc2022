use v6;
use MONKEY;

my $file = open 'sample.txt';
my @monkeys;

my %current_monkey;
for $file.lines -> $line {
  given $line.trim {
    when /Monkey/ { %current_monkey = :num_inspections(0); }
    when /"Starting items: "[(\d+)[", "]?]+/ {
      %current_monkey{'items'} = $0.map({ +$_ });
    }
    when /"Operation: new = "(\N+)/ {
      %current_monkey{'op'} = $0.subst("old", "\$old", :g);
    }
    when /"Test: divisible by "(\d+)/ {
      %current_monkey{'divisible_by'} = +$0;
    }
    when /"If true: throw to monkey "(\d+)/ {
      %current_monkey{'if_true'} = +$0;
    }
    when /"If false: throw to monkey "(\d+)/ {
      %current_monkey{'if_false'} = +$0;
      @monkeys.push: {%current_monkey}; 
    }
    when "" { next; }
    default { die "unexpected line: " ~ $line }
  }
}

for @monkeys -> %monkey {
  for @(%monkey{'items'}) -> $item {
    %monkey{'num_inspections'}++;
  }
}
