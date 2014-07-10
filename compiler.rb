#!/usr/bin/ruby

# compiler.rb
# Written by John Musgrave
#   Main compiler invocation

dir = File.dirname(__FILE__)
require "#{dir}/src/parser.rb"

class Compiler
  def initialize(filename)    
    @parser = Parser.new(filename)
    @parser.start()
  end
end

# get filename from command line arg
file_in = ARGV[0]
compiler = Compiler.new(file_in)
