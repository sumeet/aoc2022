lines = open("input.txt").readlines
lines.each do |line|
  lhs, rhs = line.chomp.split(': ')
  eval "def #{lhs}; #{rhs} ; end"
end
PART1 = root
puts "part 1: #{PART1}"


lines.each do |line|
  lhs, rhs = line.chomp.split(': ')
  if lhs == "root"
    $root_lhs, _, $root_rhs = rhs.split(' ')
    rhs = "(#{$root_lhs} - #{$root_rhs})"
  end
  eval "def #{lhs}; Arith.wrap(#{rhs}) ; end"
end

class Arith
  def self.wrap(a)
    if a.is_a?(Arith)
      a
    else
      Arith.new(a)
    end
  end

  def initialize(s)
    @s = s
  end

  def to_s
    @s.to_s
  end

  def type
    @s.is_a?(Integer) ? :int : :irred
  end

  ["+", "-", "*", "/"].each do |op|
    define_method(op.to_sym) do |other|
      if self.type == :int && other.type == :int
        return Arith.wrap(eval("#{self} #{op} #{other}"))
      end
      Arith.new("(#{self} #{op} #{other})")
    end
  end
end

def humn ; Arith.new("humn") ; end

lhs = method($root_lhs.to_sym).call.to_s
rhs = method($root_rhs.to_sym).call.to_s

f = <<-PYTHON
from sympy import Symbol, solve, Eq, simplify

humn = Symbol("humn")
print(solve(Eq(#{lhs}, #{rhs}), humn)[0])
PYTHON

$solved = Integer(`python -c '#{f}'`.chomp)
puts "part 2: #{$solved}"