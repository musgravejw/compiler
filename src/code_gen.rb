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
  end

  def op(r1, r2, operator)
  	gen("R[1] = #{r1};")
  	gen("R[2] = #{r2};")
  	gen("R[1] = R[1] #{operator} R[2];")
  end
end