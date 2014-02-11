# parser.rb
# Abstract:  LL(1) Recursive Descent parser
# Uses scanner to build abstract syntax tree
# Grammar requirements for each method are stated in BNF notaion above

require './scanner.rb'

class Parser
  @token = ""

  def initialize(filename)  	
    @scanner = Scanner.new(filename)    
  end

  def increment
    @token = @scanner.get_next_token()
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
      increment()
      if @token.class == "keyword" && @token.lexeme == "program"        
        if identifier() == true
          increment()
          if @token.class == "keyword" && @token.lexeme == "is"
            result = true
          end
        end
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
        end
      end
      return result
    end

    def program_declaration
      result = false      
      if @token.class == "left_paren"        
        if declaration() == true
          increment()
          if @token.class == "semi_colon"
            increment()
            if @token.class == "right_paren"
              increment()
              if @token.class == "keyword" && @token.lexeme == "begin"
                result = true
              else
                program_declaration()
              end              
            end
          end
        end
      end
      return result
    end

    def program_statement
      result = false      
      if @token.class == "left_paren"        
        if statement() == true
          increment()
          if @token.class == "semi_colon"
            increment()
            if @token.class == "right_paren"
              increment()
              if @token.class == "keyword" && @token.lexeme == "end"
                increment()
                if @token.class == "keyword" && @token.lexeme == "program"
                  result = true
                end
              else
                program_statement()
              end              
            end
          end
        end
      end
      return result
    end

    # <declaration> ::=
    #   [ global ] <procedure_declaration>
    # | [ global ] <variable_declaration>
    def declaration
      result = false
      increment()
      if @token.class == "keyword" && @token.lexeme == "global"          
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
      increment()
      if @token.class == "keyword" && @token.lexeme == "procedure"
        if identifier() == true
          increment()
          if @token.class == "left_paren"      
            if parameter_list() == true
              increment()
              if @token.class == "right_paren"            
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
      result = false
      if parameter() == true
        increment()
        if @token.class == "comma"
          if parameter_list() == true
            result = true
          end
        else
          result = true
        end
      end
      return result
    end

    # <parameter> ::= <variable_declaration> (in | out)
    def parameter
      result = false
      if variable_declaration() == true
        increment()
        if @token.class == "left_paren"
          @increment
          if @token.class == "keyword" && @token.lexeme == "in" || @token.class == "keyword" && @token.lexeme == "out"
            increment()
            if @token.class == "right_paren"
              result = true
            end
          end
        end
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
      if procedure_declaration() == true
        increment()
        if procedure_statement() == true
          result = true
        end
      end
      return result
    end

    def procedure_declaration
      result = false      
      if @token.class == "left_paren"        
        if declaration() == true
          increment()
          if @token.class == "semi_colon"
            increment()
            if @token.class == "right_paren"
              increment()
              if @token.class == "keyword" && @token.lexeme == "begin"
                result = true
              else
                procedure_declaration()
              end              
            end
          end
        end
      end
      return result
    end

    def procedure_statement
      result = false      
      if @token.class == "left_paren"        
        if statement() == true
          increment()
          if @token.class == "semi_colon"
            increment()
            if @token.class == "right_paren"
              increment()
              if @token.class == "keyword" && @token.lexeme == "end"
                increment()
                if @token.class == "keyword" && @token.lexeme == "procedure"
                  result = true
                end
              else
                procedure_statement()
              end              
            end
          end
        end
      end
      return result
    end

    # <variable_declaration> ::=
    #   <type_mark> <identifier> 
    #   [ [ <array_size> ] ]
    def variable_declaration
      result = false
      if type_mark() == true
        if identifier() == true
          increment()
          if @token.class == "left_bracket"
            if array_size() == true
              increment()
              if @token.class == "right_bracket"
                result = true
              end
            end
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
      increment()
      if @token.class == "keyword"
        if @token.lexeme == "integer"
          result = true
        elsif @token.lexeme == "float"
          result = true
        elsif @token.lexeme == "bool"
          result = true
        elsif @token.lexeme == "string"
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
      return assignment_statement() || if_statement() || loop_statement() || return_statement() || procedure_call()
    end

    # <procedure_call> ::=
    #   <identifier> ( [<argument_list>] )
    def procedure_call      
      result = false
      if identifier() == true
        increment()
        if @token.class == "left_paren"
          if argument_list() == true
            increment()
            if @token.class == "right_paren"
              result = true
            end
          end
        end
      end
      return result
    end

    # <assignment_statement> ::=
    #   <destination> := <expression>
    def assigment_statement
      # *****************
      # string literal :=
      # *****************
      return destination() && expression()
    end

    # <destination> ::= 
    #   <identifier> [ [ <expression> ] ]
    def destination
      result = false
      if identifier() == true
        increment
        if @token.class == "left_bracket"
          if expression() ==  true
            increment()
            if @token.class == "right_bracket"
              result = true
            end
          end
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
      if @token.class == "keyword" && @token.lexeme == "if"
        increment()
        if @token.class == "left_paren"
          if expression() == true
            increment()
            if @token.class == "right_paren"
              increment()
              if @token.class == "keyword" && @token.lexeme == "then"
                if statement() == true
                  increment()
                  until @token.lexeme == "end" || @token.lexeme == "else"
                    if statement() == true
                      increment()
                      if @token.class != "semi_colon"
                        return false
                      end
                  end
                  increment()
                  if @token.class == "keyword" && @token.lexeme == "else"
                    if statement() == true
                      increment()
                      until @token.lexeme == "end"
                        if statement() == true
                          increment()
                          if @token.class != "semi_colon"
                            return false
                          end
                        end
                    end
                  end
                  increment()
                  if @token.class == "keyword" && @token.lexeme == "if"
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

    # <loop_statement> ::=
    #   for ( <assignment_statement> ; 
    #     <expression> ) 
    #     ( <statement> ; )*
    #   end for
    def loop_statement
    end

    # <return_statement> ::= return
    def return_statement
      result = false
      increment()
      if @token.class == "keyword" && @token.lexeme == "return"
        result = true
      end
      return result
    end

    # <identifier> ::= [a-zA-Z][a-zA-Z0-9_]*
    def identifier
      result =!(@next[/[a-zA-Z][a-zA-Z0-9_]*/]).nil?
      increment()
      return result
    end

    # <expression> ::=
    #   <expression> & <arithOp>
    # | <expression> | <arithOp>
    # | [ not ] <arithOp>    
    def expression

    end

    # <arithOp> ::=
    #   <arithOp> + <relation>
    # | <arithOp> - <relation>
    # | <relation>
    def arithmetic_operator

    end

    # <relation> ::=
    #   <relation> < <term>
    # | <relation> >= <term>
    # | <relation> <= <term>
    # | <relation> > <term>
    # | <relation> == <term>
    # | <relation> != <term>
    # | <term>
    def relational_operator

    end

    # <term> ::= 
    #   <term> * <factor>
    # | <term> / <factor>
    # | <factor>
    def term
      result = false
      if term() && factor()
        result = true
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
    end

    # <name> ::= 
    # <identifier> [ [ <expression> ] ]
    def name
      return identifier() && expression()
    end

    # <argument_list> ::=
    #   <expression> , <argument_list>
    # | <expression>
    def argument_list
    end

    # <number> ::= [0-9][0-9_]*[.[0-9_]*]
    def number
      increment()
      return @token.class == "integer"      
    end

    def string
      increment()
      return @token.class == "string"
    end   
end
