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
  end

  def reg
    @stack.size
  end

  def gen(str)
    @program += str + "\n"
  end

  def load(address, value)
    unless value.nil?
      self.gen("R[" + reg.to_s + "] = MM[#{address}];")
      @stack << value
    end
  end

  def store(value)
    unless value.nil?
      self.gen("R[" + reg.to_s + "] = " + value.to_s + ";")
      @stack << value
    end
  end

  def op(operator)
    unless operator.size <= 0
      self.gen("R[" + (reg - 1).to_s + "] = R[" + (reg - 2).to_s + "] #{operator} R[" + (reg - 1).to_s + "];")
    end

    def assignment(address)
      self.gen("MM[#{address}] = R[" + (reg - 1).to_s + "];")
    end

    def output
      if !Dir.open("target")
        Dir.mkdir "target"
      end

      File.open("target/target_" + Time.now.strftime("%Y%m%d%H%M%S%L"), 'w') do |file| 
        file.write @program
      end
    end
  end
end