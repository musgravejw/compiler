#!/usr/bin/ruby

# code_gen.rb
# John Musgrave
# Abstract
#   Class for code generation
#   Implementation of a n-register stack machine

class CodeGen
  def initialize
    @stack = []
    @program = ""
  end

  def reg
    @stack.size
  end

  def gen(str)
    @program += str
    puts str
  end

  def load(address, value)
    unless value.nil?
      self.gen("R[" + self.reg.to_s + "] = MM[#{address}];")
      @stack.push value
    end
  end

  def op(operator)
    self.gen("R[" + (@stack.size - 1).to_s + "] = R[" + @stack.size.to_s + "] #{operator} R[" + (@stack.size - 1).to_s + "];")

    if operator == "+"
      @stack.push @stack.pop + @stack.pop
    elsif operator == "-"
      @stack.push @stack.pop - @stack.pop
    elsif operator == "*"
      @stack.push @stack.pop * @stack.pop
    elsif operator == "/"
      @stack.push @stack.pop / @stack.pop
    end    
  end
end