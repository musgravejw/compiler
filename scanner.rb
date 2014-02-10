# scanner.rb
# John Musgrave
# Abstract:  This is the scanner to handle our lexical analysis.  
# Identifies the token class of each lexeme.

class Scanner
  @line = 0
  @col = 0
  @error = ""  
  @filename = ""
  @symbol_table = []

  @whitespace = []
  @operators = []
  @keywords = []
  @left_paren = ""
  @right_paren = ""
  @semi_colon = ""
  @assignment = ""
  @colon = ""
  @comma = ""
  @colon_equals = ""
  @reserved_words = []

  def initialize(file)
    @line = 0
    @col = 0
    @error = ""
    @symbol_table = []
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

      if row.nil?
        row = "EOF"
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
          when "/" && row[i-1] == "/"
            @col += 1
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
    return token
  end

  private

    def create_token(lexeme)
      token = {}
      # check the token class      
      if is_numeric? lexeme
        token['class'] = "integer"
      elsif is_string? lexeme
        token['class'] = "string"
      elsif @operators.include? lexeme
        token['class'] = "operator"
      elsif @reserved_words.include? lexeme
        token['class'] = "reserved_word"
      elsif @keywords.include? lexeme
        token['class'] = "keyword"
      elsif lexeme == @left_paren
        token['class'] = "left_paren"
      elsif lexeme == @right_paren
        token['class'] = "right_paren"
      elsif lexeme == @semi_colon
        token['class'] = "semi_colon"
      elsif lexeme == @assignment
        token['class'] = "assignment"
      elsif lexeme == @colon
        token['class'] = "colon"
      elsif lexeme == @comma
        token['class'] = "comma"
      elsif lexeme == @colon_equals
        token['class'] = "colon_equals"      
      else
        token['class'] = "identifier" unless !is_identifier? lexeme
      end      
      token['lexeme'] = lexeme      
      @symbol_table.push(token)
      return token
    end

    def is_identifier?(str)
      return !(str[/[a-zA-Z][a-zA-Z0-9_]*/]).nil?
    end

    def is_string?(str)
      return !(str[/"[a-zA-Z0-9 _,;:.']*"/]).nil?
    end

    def is_numeric?(str)
      return !(str[/[0-9][0-9_]*[.[0-9_]*]?/]).nil?
    end

    def set_symbols()
      # define token class members
      @whitespace = [" ", "\n", "\t", "\r"]
      @operators = ["+", "-", "/", "*", "==", "!=", "!", "&&", "||"]      
      @keywords = ["string", "case", "int", "for", "bool", "and", "float", "or", "global", "not", "in", "program", "out", "procedure", "if", "begin", "then", "return", "else", "end"]
      @left_paren = "("
      @right_paren = ")"
      @left_brace = "{"
      @right_brace = "}"
      @semi_colon = ";"
      @assignment = "="
      @colon = ":"
      @comma = ","
      @colon_equals = ":="
      @reserved_words = ["string", "case", "int", "for", "bool", "and", "float", "or", "global", "not", "in", "program", "out", "procedure", "if", "begin", "then", "return", "else", "end", "EOF"]
    end
end

# create new file
#File.open('test.rb', 'w') do |f|
  # write  
#end
