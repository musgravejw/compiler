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
  	#puts str
  end

  def op(r1, r2, operator)
  	# if the types match
    if r1 == r2
  	  gen("R[1] = R[0] #{operator} R[1];")
  	else
  	  puts "Type mismatch"
  	end
  end
end