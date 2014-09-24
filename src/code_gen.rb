#!/usr/bin/ruby

# code_gen.rb
# John Musgrave
# Abstract
#   Class for code generation
#   Implementation of a n-register stack machine

dir = File.dirname(__FILE__)
require "#{dir}/runtime.rb"

class CodeGen
  def initialize
    r = Runtime.new
    @stack = [0]
    @program = r.load_runtime_code_generation
    @labels = 0
    @margin = ""
  end

  def reg
    @stack.size
  end

  def gen(str)
    @program += str + "\n"
  end

  def indent
    @margin << "\t"
  end

  def outdent
    @margin = @margin[0...-2]
  end

  def margin
    @margin
  end

  def load(address)
    self.gen(@margin + "R[" + reg.to_s + "] = MM[#{address}];")
  end

  def load2(value)
    self.gen(@margin + "R[2] = #{value}")
  end

  def store(address)
    self.gen(@margin + "MM[#{address}] = " + "R[" + reg.to_s + "];")
  end

  def mem(address, value)
    self.gen(@margin + "MM[#{address}] = #{value}")
  end

  def op(operator)
    unless operator.size <= 0
      self.gen(@margin + "R[" + reg.to_s + "] = R[" + reg.to_s + "] #{operator} R[" + (reg + 1).to_s + "];")
    end
  end

  def label
    @labels += 1
    return @labels
  end

  def output
    if !Dir.exists?("target")
      Dir.mkdir "target"
    end

    File.open("target/target_" + Time.now.strftime("%Y%m%d%H%M%S%L"), 'w') do |file| 
      file.write @program
    end
  end
end