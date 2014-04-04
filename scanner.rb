# scanner.rb
# John Musgrave
# Abstract:  This is the scanner to handle our lexical analysis.  
#   Identifies the token class of each lexeme.

class Scanner
  attr_accessor :line, :col

  def initialize(file)
    @line = 1
    @col = 0
    @error = ""  
    @filename = ""
    @whitespace = []
    @operators = []
    @keywords = []
    @left_paren = ""
    @right_paren = ""
    @left_brace = ""
    @right_brace = ""
    @left_bracker = ""
    @right_bracket = ""
    @semi_colon = ""
    @assignment = ""
    @colon = ""
    @comma = ""
    @colon_equals = ""      
    @filename = file
    set_symbols()
  end

  def get_next_token
    if @filename.nil?
      # file not found
      puts "Fatal:  File not found.  Please enter a valid filename."
    else
      begin
        file = File.open(@filename, 'r')  # open the file    
      rescue
        abort "Fatal:  File not found.  Please enter a valid filename."
      end

      token = {}
      lexeme = ""
      i = 0      

      (@line - 1).times{file.gets}  # move to the current line
      row = file.gets.strip

      if row.nil?
        puts "=> Scan completed.\n\n"
      elsif @col >= row.size  # if we are at the end of line
        row = file.gets

        if row.nil?          
          token['class'] = "whitespace"
          token['lexeme'] = "EOF"
          return token
        end

        row = row.strip
        @line += 1
        @col = 0
      end      

      row.each_char do |c|      # look at each character 
        if i >= @col            # ignore if we've checked it before
          if c == "\n"          
            @line += 1
            @col = 0
            break   
          elsif @whitespace.include? c            
            @col += 1
            break
          #elsif c == "/" && row[i-1] == "/"
            #@col += 1      
          elsif lexeme.size == 0
            if @left_paren == c
              @col += 1
              token['class'] = "left_paren"
              token['lexeme'] = c
              break
            elsif @right_paren == c
              @col += 1
              token['class'] = "right_paren"
              token['lexeme'] = c
              break
            elsif @left_brace == c
              @col += 1
              token['class'] = "left_brace"
              token['lexeme'] = c
              break
            elsif @right_brace == c
              @col += 1
              token['class'] = "right_brace"
              token['lexeme'] = c
              break
            elsif @left_bracket == c
              @col += 1
              token['class'] = "left_bracket"
              token['lexeme'] = c
              break
            elsif @right_bracket == c
              @col += 1
              token['class'] = "right_bracket"
              token['lexeme'] = c
              break
            elsif @semi_colon == c
              @col += 1
              token['class'] = "semi_colon"
              token['lexeme'] = c
              break            
            elsif @comma == c
              @col += 1
              token['class'] = "comma"
              token['lexeme'] = c
              break
            else            
              @col += 1
              lexeme += c              
            end
          else
            case c
            when @left_paren
              break
            when @right_paren
              break
            when @left_brace
              break
            when @right_brace
              break
            when @left_bracket
              break
            when @right_bracket
              break
            when @semi_colon
              break            
            when @comma
              break                    
            else            
              @col += 1
              lexeme += c              
            end
          end
        end
        i += 1        
      end
      if token['class'].nil? && lexeme.size > 0        
        token = create_token(lexeme)    
      end
      if token.empty?
        token = get_next_token()
      end
      #puts token
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
      elsif @keywords.include? lexeme
        token['class'] = "keyword"     
      elsif lexeme == @colon_equals
        token['class'] = "colon_equals"      
      else
        token['class'] = "identifier" unless !is_identifier? lexeme
      end      
      token['lexeme'] = lexeme
      return token
    end

    def is_identifier?(str)
      return !(str[/[a-zA-Z][a-zA-Z0-9_]*/]).nil?
    end

    def is_string?(str)
      return !(str.match(/\"[a-zA-Z0-9 _,;:.']*\"/)).nil?
    end

    def is_numeric?(str)
      return !(str.match(/[0-9][0-9_]*[.[0-9_]*]?/)).nil?
    end

    def set_symbols()
      # define token class members
      @whitespace = [" ", "\n", "\t", "\r"]
      @operators = ["+", "-", "/", "*", ">", ">=", "<", "<=", "==", "!=", "!", "&&", "||"]      
      @keywords = ["string", "case", "int", "for", "bool", "and", "float", "or", "global", "not", "in", "program", "out", "procedure", "if", "begin", "then", "return", "else", "end", "EOF", "is"]
      @left_paren = "("
      @right_paren = ")"
      @left_brace = "{"
      @right_brace = "}"
      @left_bracket = "["
      @right_bracket = "]"
      @semi_colon = ";"
      @assignment = "="
      @colon = ":"
      @comma = ","
      @colon_equals = ":="
    end
end

# create new file
#File.open('test.rb', 'w') do |f|
  # write  
#end
