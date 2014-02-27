# parser.rb
# Abstract:  LL(1) Recursive Descent parser
#   Uses scanner to build abstract syntax tree
#   Grammar requirements for each method are stated in BNF notaion above

require './scanner.rb'

class Parser
  @token = {}
  @next = {}
  @buffer = []
  BUFFER_SIZE = 3

  def initialize(filename)  	
    @scanner = Scanner.new(filename)
    @token = {}
    @next = {}
    @buffer = []
    peek()
  end

  def peek
    @next = @scanner.get_next_token()    
  end

  def increment
    @token = @next
    peek()
    @buffer.push(@next)
    @buffer.shift if @buffer.size > BUFFER_SIZE
  end

  def resync    
    @next = @buffer[1]
    @token = @buffer[0]
  end

  def error(str)
    puts "=> Parse error [line #{@scanner.line}, col #{@scanner.col}]:  \"invalid #{str}\" for token '#{@next['lexeme']}'."
  end

  def start
    return program()
  end

  private
    # <program> ::= 
    #   <program_header> <program_body>
    def program      
      return program_header() && program_body()
    end

    # <program_header> ::= program <identifier> is
    def program_header
      result = false      
      return false if @next.nil?
      if @next['class'] == "keyword" && @next['lexeme'] == "program"
        increment()
        if identifier() == true
          increment()
          if @next['class'] == "keyword" && @next['lexeme'] == "is"
            result = true
          else
            error("program_header")
          end
        else
          error("program_header")
        end
      else
        error("program_header")
      end
      return result
    end

    # <program_body> ::= 
    #     ( <declaration> ; )*
    #   begin
    #     ( <statement> ; )*
    #   end program
    def program_body
      result = false      
      increment()
      if program_declaration() == true
        increment()        
        if program_statement() == true
          result = true
        else
          error("statement")
        end
      else
        error("declaration")
      end
      return result
    end

    def program_declaration      
      result = false
      #if @next['class'] == "left_paren"
      if declaration() == true
        increment()
        if @next['class'] == "semi_colon"
          #increment()
          #if @next['class'] == "right_paren"
          increment()
          if @next['class'] == "keyword" && @next['lexeme'] == "begin"
            result = true
          else
            result = program_declaration()
          end
        end
      elsif @next['class'] == "keyword" && @next['lexeme'] == "begin"
        result = true
      end
      return result
    end

    def program_statement
      result = false
      #if @next['class'] == "left_paren"
      if statement() == true
        increment()
        if @next['class'] == "semi_colon"
          #increment()
          #if @next['class'] == "right_paren"
          increment()
          if @next['class'] == "keyword" && @next['lexeme'] == "end"
            increment()
            if @next['class'] == "keyword" && @next['lexeme'] == "program"
              result = true
            end
          else
            result = program_statement()
          end              
        #end
        end
      elsif @next['class'] == "keyword" && @next['lexeme'] == "end"
        increment()
        if @next['class'] == "keyword" && @next['lexeme'] == "program"
          result = true
        end
      end
      #end
      return result
    end

    # <declaration> ::=
    #   [ global ] <procedure_declaration>
    # | [ global ] <variable_declaration>
    def declaration
      result = false      
      if @next['class'] == "keyword" && @next['lexeme'] == "global"          
        if procedure_declaration() == true || variable_declaration() == true
          result = true          
        end
      else        
       if procedure_declaration() == true || variable_declaration() == true          
          result = true          
        end
      end
      return result
    end

    # <procedure_declaration> ::= 
    #   <procedure_header> <procedure_body>
    def procedure_declaration      
      return procedure_header() && procedure_body()
    end

    # <procedure_header> :: = 
    #   procedure <identifier> 
    #     ( [<parameter_list>] )
    def procedure_header
      result = false            
      if @next['class'] == "keyword" && @next['lexeme'] == "procedure"
        increment()        
        if identifier() == true
          increment()
          if @next['class'] == "left_paren"
            increment()            
            if parameter_list() == true
              if @next['class'] == "right_paren"                
                result = true                
              end
            end
          end
        end
      end
      return result
    end

    # <parameter_list> ::= 
    #   <parameter> , <parameter_list>
    # | <parameter>
    def parameter_list
      #puts "\n=> Called parameter_list\n"
      result = false
      if parameter() == true
        increment()        
        if @next['class'] == "comma"
          increment()
          result = parameter_list()
        else
          result = true
        end
      end
      return result
    end

    # <parameter> ::= <variable_declaration> (in | out)
    def parameter
      #puts "\n=> Called parameter\n"
      result = false      
      if variable_declaration() == true
        #increment()
        #if @token['class'] == "left_paren"        
        increment()        
        if @next['class'] == "keyword" && @next['lexeme'] == "in" || @next['class'] == "keyword" && @next['lexeme'] == "out"          
          #if @token['class'] == "right_paren"
          result = true
          #end
        end
        #end
      end
      return result      
    end

    # <procedure_body> ::= 
    #     ( <declaration> ; )*
    #   begin
    #     ( <statement> ; )*
    #   end procedure
    def procedure_body
      result = false
      increment()
      if procedure_body_declaration() == true        
        increment()        
        if procedure_body_statement() == true          
          result = true
        end
      end
      return result
    end

    def procedure_body_declaration
      result = false
      #if @next['class'] == "left_paren
      if declaration() == true
        increment()
        if @next['class'] == "semi_colon"
          #increment()
          #if @next['class'] == "right_paren"
          increment()
          if @next['class'] == "keyword" && @next['lexeme'] == "begin"
            result = true
          else
            result = procedure_body_declaration()
          end
          #end
        end
      elsif @next['class'] == "keyword" && @next['lexeme'] == "begin"
        result = true
      end
      #end
      return result
    end

    def procedure_body_statement
      result = false      
      #if @next['class'] == "left_paren"      
      if statement() == true        
        increment()
        if @next['class'] == "semi_colon"
          increment()
          #if @next['class'] == "right_paren"
          increment()
          if @next['class'] == "keyword" && @next['lexeme'] == "end"
            increment()
            if @next['class'] == "keyword" && @next['lexeme'] == "procedure"
              result = true
            end
          else
            result = procedure_body_statement()
          end
          #end
        end
      elsif @next['class'] == "keyword" && @next['lexeme'] == "end"
        increment()
        if @next['class'] == "keyword" && @next['lexeme'] == "procedure"
          result = true
        end      
      end
      #end
      return result
    end

    # <variable_declaration> ::=
    #   <type_mark> <identifier> 
    #   [ [ <array_size> ] ]
    def variable_declaration
      #puts "\n=> Called variable_declaration\n\n"
      result = false      
      if type_mark() == true
        increment()
        if identifier() == true
          if @next['class'] == "left_bracket"
            if array_size() == true              
              if @next['class'] == "right_bracket"
                result = true
              end            
            end
          else
            result = true
          end        
        end      
      end
      return result      
    end

    # <type_mark> ::=
    #   integer
    # | float
    # | bool
    # | string
    def type_mark      
      result = false
      if @next['class'] == "keyword"
        if @next['lexeme'] == "int"
          result = true          
        elsif @next['lexeme'] == "float"
          result = true          
        elsif @next['lexeme'] == "bool"
          result = true          
        elsif @next['lexeme'] == "string"
          result = true          
        end
      end
      return result
    end

    # <array_size> ::= <number>
    def array_size
      return number()
    end

    # <statement> ::=
    #   <assignment_statement>
    # | <if_statement>
    # | <loop_statement>
    # | <return_statement>
    # | <procedure_call>
    def statement
      return assignment_statement() #|| if_statement() || loop_statement() || return_statement() || procedure_call()
    end

    # <procedure_call> ::=
    #   <identifier> ( [<argument_list>] )
    def procedure_call      
      result = false
      if identifier() == true
        increment()
        if @token['class'] == "left_paren"
          if argument_list() == true
            increment()
            if @token['class'] == "right_paren"
              result = true
            end
          end
        end
      end
      return result
    end

    # <assignment_statement> ::=
    #   <destination> := <expression>
    def assignment_statement
      result = false      
      if destination() == true
        increment()
        resync() if @token['class'] == "colon_equals"
        if @next['class'] == "colon_equals"
          increment()
          puts
          puts "current"
          puts @token.to_s
          puts "next"
          abort @next.to_s
          if expression() == true
            result = true
            puts "valid assignment_statement"
          end        
        end
      end
      return result      
    end

    # <destination> ::= 
    #   <identifier> [ [ <expression> ] ]
    def destination
      result = false           
      if identifier() == true
        increment
        if @next['class'] == "left_bracket"
          increment()
          if expression() ==  true
            increment()
            if @next['class'] == "right_bracket"
              result = true
            end
          end
        else
          result = true          
        end      
      end
      return result
    end

    # <if_statement> ::=
    #   if ( <expression> ) then ( <statement> ; )+
    #   [ else ( <statement> ; )+ ]
    #   end if
    def if_statement
      result = false
      increment()
      if @token['class'] == "keyword" && @token['lexeme'] == "if"
        increment()
        if @token['class'] == "left_paren"
          if expression() == true
            increment()
            if @token['class'] == "right_paren"
              increment()
              if @token['class'] == "keyword" && @token['lexeme'] == "then" && statement() == true                
                increment()
                until @token['lexeme'] == "end" || @token['lexeme'] == "else"
                  if statement() == true
                    increment()
                    if @token['class'] != "semi_colon"
                      return false
                    end
                  end
                end
                increment()
                if @token['class'] == "keyword" && @token['lexeme'] == "else"
                  if statement() == true
                    increment()
                    until @token['lexeme'] == "end"
                      if statement() == true
                        increment()
                        if @token['class'] != "semi_colon"
                          return false
                        end
                      end
                    end
                  end
                end
                increment()
                if @token['class'] == "keyword" && @token['lexeme'] == "if"
                  result = true
                end                
              end
            end
          end
        end
      end
      return result
    end   

    # <loop_statement> ::=
    #   for ( <assignment_statement> ; 
    #     <expression> ) 
    #     ( <statement> ; )*
    #   end for
    def loop_statement
      result = false
      increment()
      if @token['class'] == "keyword" && @token['lexeme'] == "for"
        increment()
        if @token['class'] == "left_paren"
          if assignment_statement() == true
            increment()
            if @token['class'] == "semi_colon"
              if expression() == true
                until statement() == true
                  statement()
                  increment()
                  if @token['class'] != "semi_colon"
                    return false
                  end
                end
                increment()
                if @token['class'] == "keyword" && @token['lexeme'] == "end"
                  increment()
                  if @token['class'] == "keyword" && @token['lexeme'] == "for"
                    result = true
                  end
                end
              end
            end
          end
        end
      end
      return result
    end

    # <return_statement> ::= return
    def return_statement
      result = false
      increment()
      if @token['class'] == "keyword" && @token['lexeme'] == "return"
        result = true
      end
      return result
    end

    # <identifier> ::= [a-zA-Z][a-zA-Z0-9_]*
    def identifier      
      return !(@next['lexeme'].match(/[a-zA-Z][a-zA-Z0-9_]*/)).nil?
    end

    # <expression> ::=
    #   <expression> & <arithmetic_operator>
    # | <expression> | <arithmetic_operator>
    # | [ not ] <arithmetic_operator>    
    def expression
      result = false
      puts
      puts
      abort @next.to_s
      if !arithmetic_operator() == true
        result = true
      elsif expression() == true        
        increment()
        if @next['class'] == "operator" && @next['lexeme'] == "&"
          increment()
          if arithmetic_operator() == true
            result = true
          end
        elsif @next['class'] == "operator" && @next['lexeme'] == "|"
          increment()
          if arithmetic_operator() == true
            result = true
          end
        end
      end
      return result
    end

    # <arithmetic_operator> ::=
    #   <arithmetic_operator> + <relation>
    # | <arithmetic_operator> - <relation>
    # | <relation>
    def arithmetic_operator
      result = false
      if relation() == true
        result = true
      elsif arithmetic_operator() == true
        increment()
        if @next['class'] == "operator" && @next['lexeme'] == "+"
          if relation() == true
            result = true
          end
        elsif @next['class'] == "operator" && @next['lexeme'] == "-"
          if relation() == true
            result = true
          end
        end          
      end
      return result
    end

    # <relation> ::=
    #   <relation> < <term>
    # | <relation> >= <term>
    # | <relation> <= <term>
    # | <relation> > <term>
    # | <relation> == <term>
    # | <relation> != <term>
    # | <term>
    def relation
      result = false
      if term() == true
        result = true
      elsif relation() == true
        increment()
        if @next['class'] == "operator" && @next['lexeme'] == "<"
          increment()
          if term() == true
            result = true
          end
        elsif @next['class'] == "operator" && @next['lexeme'] == ">="
          increment()
          if term() == true
            result = true
          end
        elsif @next['class'] == "operator" && @next['lexeme'] == "<="
          increment()
          if term() == true
            result = true
          end
        elsif @next['class'] == "operator" && @next['lexeme'] == ">"
          increment()
          if term() == true
            result = true
          end
        elsif @next['class'] == "operator" && @next['lexeme'] == "=="
          increment()
          if term() == true
            result = true
          end
        elsif @next['class'] == "operator" && @next['lexeme'] == "!="
          increment()
          if term() == true
            result = true
          end
        end
      end
      return result
    end

    # <term> ::= 
    #   <term> * <factor>
    # | <term> / <factor>
    # | <factor>
    def term
      result = false
      if factor() == true
        result = true
      elsif term() == true
        increment()        
        if @next['class'] == "operator" 
          if @next['lexeme'] == "*" && factor() == true
            result = true
          elsif @next['lexeme'] == "/" && factor() == true
            result = true
          end
        end
      end
      return result
    end

    # <factor> ::= 
    #   ( <expression> ) 
    # | [ - ] <name> 
    # | [ - ] <number> 
    # | <string>
    # | true
    # | false
    def factor
      result = false
      increment()
      if @next['class'] == "left_paren" && expression() == true        
        increment()
        if @next['class'] == "right_paren"
          result = true
        end
      elsif name() == true
        result = true
      elsif number() == true
        result = true
      elsif @next['class'] == "operator" && @next['lexeme'] == "-"        
        increment()
        if name() == true
          result = true
        elsif number() == true
          result = true
        end
      elsif string() == true
        result = true
      elsif @next['class'] == "keyword"
        if @next['lexeme'] == "true"
          result = true
        elsif @next['lexeme'] == "false"
          result = true
        end
      end
      return result
    end

    # <name> ::= 
    # <identifier> [ [ <expression> ] ]
    def name
      result = false
      if identifier() == true
        increment()
        if @next['class'] == "left_bracket" && expression() == true          
          increment()
          if @next['class'] == "right_bracket"
            result = true
          end
        else
          result = true
        end
      end
      return result
    end

    # <argument_list> ::=
    #   <expression> , <argument_list>
    # | <expression>
    def argument_list
      result = false
      if expression() == true
        increment()
        if @next['class'] == "comma"
          increment()
          if argument_list() == true
            result = true
          end
        else
          result = true
        end
      end
      return result
    end

    # <number> ::= [0-9][0-9_]*[.[0-9_]*]
    def number     
      return @next['class'] == "integer"
    end

    def string
      return @next['class'] == "string"
    end   
end
