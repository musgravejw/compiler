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
    @program += str + "\n"
  end

  def load(address, value)
    unless value.nil?
      self.gen("R[" + self.reg.to_s + "] = MM[#{address}];")
      @stack.push value
    end
  end

  def store(value)
    unless value.nil?
      @stack.push value
    end
  end

  def op(operator)
    unless operator.size <= 0
      self.gen("R[" + (@stack.size - 1).to_s + "] = R[" + (@stack.size - 2).to_s + "] #{operator} R[" + (@stack.size - 1).to_s + "];")

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

    def assignment(address)
      self.gen("MM[#{address}] = R[" + (self.reg - 1).to_s + "];")
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