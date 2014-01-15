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
      token = {}
      lexeme = ""
      i = 0
      file = File.open(@filename, 'r')  # open the file    
      @line.times{file.gets}  # move to the current line
      row = file.gets      

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
      token = create_token(lexeme)
      file.close()
    end
  end

  private

    def create_token(lexeme)
      token = {}
      # check the token class
      if lexeme.is_number?
        token['class'] = "integer"
      elsif @sybols.include? lexeme
      	token['class'] = "operator"
      else
      	token['class'] = "identifier"
      end
      token['lexeme'] = lexeme
      return token
    end

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
