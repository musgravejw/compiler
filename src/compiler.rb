#!/usr/bin/ruby

# compiler.rb
# Written by John Musgrave
#   Main compiler invocation

dir = File.dirname(__FILE__)
require "#{dir}/parser.rb"

class Compiler
  def initialize(filename)    
    @line = 0
    @error = ""
    @scanner = nil
    @parser = Parser.new(filename)
    @parser.start()
  end

  def reportError(message)
    puts message
  end

  def reportWarning(message)
    puts message
  end
end

# get filename from command line arg
file_in = ARGV[0]
compiler = Compiler.new(file_in)
