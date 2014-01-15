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
    set_tokens()
  end

  def get_next_token()
    if @filename.nil?
	  # file not found
	  puts "Fatal:  File not found.  Please enter a valid filename."
	else	  
	  file = File.open(@filename, 'r')  # open the file
	  
	  # move to the current line and column
	  line = get_next_line(file)
	  for i in 0..@col
	  	line.getc
	  end

	  file.close()
	end
  end

  private
    def get_next_line(file)
      @line.times{file.gets}  # move to the current line
      str = file.gets
      @line += 1
      return str
    end

  	def set_tokens()
  	  # define tokens
	  @symbols = ['=', ';', '(', ')', '{', '}', '<', '<=', '>', '>=',
        '!', '!=', '==', '&&', '||', '+', '-', '*', '/']
  	end
end

# create new file
#File.open('test.rb', 'w') do |f|
	# write  
#end

# get characters from the file
#    while c = f.getc	  	
#      if tokens.has_value? c
#        current_token += c
#      else
#        while c != ' '
#          current_token += c
#          c = f.getc
#        end	    	
#      end
#    end

# get filename from command line argument
file_in = ARGV[0]
s = Scanner.new(file_in)
puts s.get_next_token()
