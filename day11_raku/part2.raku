use v6;
use MONKEY;

my @monkeys;
my %current_monkey;

for open('input.txt').lines {
  when "" { next; }
  when /Monkey/ { %current_monkey = :num_inspections(0); }
  when /"Starting items: "[(\d+)[", "]?]+/ {
    %current_monkey<items> = $0.map({ +$_ }).Array;
  }
  when /"Operation: new = "(\N+)/ {
    my $op = $0.subst("old", "\$old", :g);
    %current_monkey<op> = EVAL("-> \$old \{ $op \}");
  }
  when /"Test: divisible by "(\d+)/ {
    %current_monkey<divisible_by> = +$0;
  }
  when /"If true: throw to monkey "(\d+)/ {
    %current_monkey<if_true> = +$0;
  }
  when /"If false: throw to monkey "(\d+)/ {
    %current_monkey<if_false> = +$0;
    @monkeys.push: {%current_monkey}; 
  }
  default { die "unexpected line: " ~ $_ }
}

my $all_divisble_bys = [*] @monkeys.map: {$_<divisible_by>};

for 1..10_000 {
  for @monkeys -> %monkey {
    for @(%monkey<items>) {
      %monkey<num_inspections>++;
      my $new = %monkey<op>($^item) % $all_divisble_bys;
      my $target = $new %% %monkey<divisible_by> ?? %monkey<if_true> !! %monkey<if_false>;
      @monkeys[$target]<items>.push: $new;
    }
    %monkey<items> = [];
  }
}

print "part 2: ";
say [*] @monkeys.map({ $_<num_inspections> }).sort[*-2..*];
