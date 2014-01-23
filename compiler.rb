# compiler.rb
# Written by John Musgrave
# Main compiler runtime

require './scanner.rb'

class Compiler
  @line = 0
  @error = ""
  @scanner = nil

  def initialize(filename)
    @scanner = Scanner.new(filename)
    start()
  end

  def start
    token = ""
    while token['lexeme'] != "EOF"
      token = @scanner.get_next_token()
      puts token.to_s
    end
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
