# scanner.rb
# John Musgrave
# Abstract:  This is the scanner to handle our lexical analysis

class Scanner
  @line = 0
  @col = 0
  @filename = ""
  @symbols = []  

  def initialize(file)
    @line = 0
    @col = 0
    @filename = file
    set_symbols()
  end

  def get_next_token()
    if @filename.nil?
    # file not found
    puts "Fatal:  File not found.  Please enter a valid filename."
  else    
    file = File.open(@filename, 'r')  # open the file
    
    @line.times{file.gets}  # move to the current line

    row = file.gets
    token = ""
    i = 0    

    row.each_char do |c|
      if i >= @col
        case c
        when ' '          
          @col = i + 1
          break
        when '\t'
          @col = i + 1
          break
        when '\n'
          @line += 1
          @col = 0
        else          
          token += c.to_s
        end
      end
      i += 1
    end

    puts token

    # add token class
    # if @sybols.include? token

    # else

    # end

    file.close()
  end
  end

  private
    def set_symbols()
      # define tokens
    @symbols = ['=', ';', '(', ')', '{', '}', '>', '<', '>=', '<=', '==', '!=', '!', '&&', '||', '+', '-', '*', '/']    
    end
end

# create new file
#File.open('test.rb', 'w') do |f|
  # write  
#end

# get filename from command line argument
file_in = ARGV[0]
s = Scanner.new(file_in)
puts s.get_next_token()

