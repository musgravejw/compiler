# compiler.rb
# Written by John Musgrave
#   Main compiler runtime

require './parser.rb'

class Compiler
  @line = 0
  @error = ""
  @scanner = nil

  def initialize(filename)    
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
