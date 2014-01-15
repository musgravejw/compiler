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
    lexeme = ""
    i = 0

    # if we are at the end of line
    if @col >= row.size
    	row = file.gets
    	@line += 1
    	@col = 0
    end

    # look at each char
    row.each_char do |c|      
      # ignore if we've checked it before
      if i >= @col      	
        case c
        when " "         
          @col = i + 1
          break
        when "\t"
          @col = i + 1
          break
        when "\n"
          @line += 1
          @col = 0
          break        
        else          
          @col += 1
          lexeme += c          
        end
      end
      i += 1
    end    

    puts lexeme

    # add token class
    # if @sybols.include? lexeme

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
