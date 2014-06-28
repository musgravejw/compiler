#!/usr/bin/ruby

# code_gen.rb
# John Musgrave
# Abstract
#   Class for code generation

class CodeGen
  def initialize
  	@register = 0
  	@program = ""
  end

  def reg
  	@register
  end

  def inc
  	@register += 1
  end

  def gen(str)
  	@program += str
  	# puts str
  end

  def load(reg, address)
    gen("R[#{reg}] = MM[#{address}]")
  end

  def op(operator)
  	gen("R[0] = R[1] #{operator} R[2];")
    @register -= 2 unless @register == 0
  end
end