# parser.rb
# Abstract:  LL(1) Recursive Descent parser
#   Uses scanner to build the parse table
#   Grammar requirements for each method are stated in BNF notaion above

require './scanner.rb'

class Parser  
  def initialize(filename)
    @next = {}
    @scanner = Scanner.new(filename)    
  end

  def next!
    # abort if check("whitespace", "EOF")
    @next = @scanner.get_next_token 
    puts @next
  end

  def check(token_class, lexeme)
    return (token_class == @next['class'] && lexeme == @next['lexeme'])    
  end

  def resync(token_class, lexeme)
    until check(token_class, lexeme)
      next!
    end
  end

  def error(str)
    puts "=> Parse error [line #{@scanner.line}, col #{@scanner.col}]:  \"invalid #{str}\" expected '#{@next['lexeme']}'."
  end

  def start
    next!
    return program
  end
  

  private
    # <program> ::= 
    #   <program_header> <program_body>
    #
    def program            
      if program_header
        next!
        if program_body
          puts "Parse completed successfully."
        else
          error("program body")
        end
      else
        error("program header")
      end
    end


    # <program_header> ::= program <identifier> is
    #
    def program_header    
      if check("keyword", "program")     
        next! 
        if identifier
          next!
          if check("keyword", "is")
            return true
          else
            error("keyword is")
          end
        else
          error("identifier")
        end
      else
        error("keyword program")
      end    
    end


    # <program_body> ::= 
    #     ( <declaration> ; )*
    #   begin
    #     ( <statement> ; )*
    #   end program
    #
    def program_body
      until !program_declaration || check("keyword", "begin")
        next!
      end    
      if check("keyword", "begin")
        next!
        until !program_statement || check("keyword", "end")
          next!
        end              
        if check("keyword", "end")
          next!
          if check("keyword", "program")
            return true
          else
            error("keyword program")
          end
        else
          error("keyword end")
        end      
      else
        error("keyword begin")
      end
    end

    
    def program_declaration         
      if declaration
        next!
        check("semi_colon", ";")
        declaration
      else 
        return true
      end
    end

    def program_statement
      if statement    
        check("semi_colon", ";")
        statement
      else
        return true
      end
    end


    # <identifier> ::= [a-zA-Z][a-zA-Z0-9_]*
    #
    def identifier    
      unless check("whitespace", "EOF")
        return !(@next['lexeme'].match(/[a-zA-Z][a-zA-Z0-9_]*/)).nil?    
      else
        return false
      end   
    end

    # <declaration> ::=
    #   [ global ] <procedure_declaration>
    #   | [ global ] <variable_declaration>
    #
    def declaration
      # check for global    
      return procedure_declaration || variable_declaration
    end

    # <statement> ::=
    #     <assignment_statement>
    #   | <if_statement>
    #   | <loop_statement>
    #   | <return_statement>
    #   | <procedure_call>
    #
    def statement
      if first("assignment")
        assignment
      elsif first("if")
        if_statement
      elsif first("loop")
        loop_statement
      elsif first("return")
        return_statement
      elsif first("procedure")
        procedure_call
      else
        error("statement")
      end      
    end

    def first(a)
      if a == "assignment"
        identifier
      elsif a == "if"
        check("keyword", "if")
      elsif a == "loop"
        check("keyword", "for")
      elsif a == "return"
        check("keyword", "return")
      elsif a == "procedure"
        check("left_paren", "(")
      end      
    end


    # <procedure_declaration> ::= 
    #   <procedure_header> <procedure_body>
    #
    def procedure_declaration        
      if procedure_header
        next!
        procedure_body
      end
    end


    # <variable_declaration> ::=
    #   <type_mark> <identifier> 
    #   [ [ <array_size> ] ]
    #
    def variable_declaration    
      if type_mark
        next!
        identifier      
        if check("left_bracket", "[")
          next!
          if array_size
            next!
            check("right_bracket", "]")
          else
            error("array size")
          end
        else
          error("left bracket")
        end
      else
        error("type mark")
      end
    end


    # <array_size> ::= <number>
    #
    def array_size
      return number
    end


    # <procedure_header> :: = 
    #   procedure <identifier> 
    #     ( [<parameter_list>] )
    #
    def procedure_header    
      if check("keyword", "procedure")
        next!
        if identifier
          next!
          if check("left_paren", "(")
            next!
            if parameter_list
              next!
              if check("right_paren", ")")
                return true
              else
                error("right paren")
              end
            else
              error("parameter list")
            end
          else
            error("left paren")
          end
        else
          error("identifier")
        end
      else
        error("keyword procedure")
      end
    end


    # <procedure_body> ::= 
    #     ( <declaration> ; )*
    #   begin
    #     ( <statement> ; )*
    #   end procedure
    # 
    def procedure_body    
      if program_declaration      
        next!
        if check("keyword", "begin")
          next!
          if program_statement
            next!
            if check("keyword", "end")
              next!                
              check("keyword", "procedure")
            else
              error("keyword end")
            end
          else
            error("program statement")
          end        
        else
          error("keyword begin")
        end
      else
        error("program declaration")
      end
    end


    # <type_mark> ::=
    #     integer
    #   | float
    #   | bool
    #   | string
    #
    def type_mark    
      return check("keyword", "int" || check("keyword", "float") || check("keyword", "bool") || check("keyword", "string"))
    end


    # <parameter_list> ::= 
    #     <parameter> , <parameter_list>
    #   | <parameter>
    #
    def parameter_list
      if parameter
        next!
        if check("comma", ",")
          next!
          if parameter_list
            return true
          else
            error("parameter list")
          end
        else
          return true
        end
      else
        error("parameter")
      end
    end


    # <parameter> ::= <variable_declaration> (in | out)
    #
    def parameter
      if variable_declaration
        next!
        check("keyword", "in") || check("keyword", "in")
      else
        error("variable declaration")
      end
    end


    # <assignment_statement> ::=
    # <destination> := <expression>
    #
    def assignment_statement
      if destination
        next!
        if check("colon_equals", ":=")
          next!
          if expression
            return true
          else
            error("expression")
          end
        else
          error("colon equals")
        end
      else
        error("destination")
      end
    end


    # <destination> ::= 
    # <identifier> [ [ <expression> ] ]
    #
    def destination
      if identifier
        next!
        return true 
      else
        error("identifier")     
      end
    end


    # <expression> ::=
    #     <expression> & <arithOp>
    #   | <expression> | <arithOp>
    #   | [ not ] <arithOp>
    #
    def expression
      arithmetic_operator || e_prime
    end

    def e_prime    
      if check("operator", "&")
        next!
        if arithmetic_operator
          next!
          e_prime
        end
      elsif check("operator", "|")
        next!
        if arithmetic_operator
          next!
          e_prime
        end
      elsif check("keyword", "not")
        next!
        if arithmetic_operator
          next!
          e_prime
        end
      elsif arithmetic_operator
        next!
        e_prime
      else
        error("expression")
      end
    end


    # <arithOp> ::=
    #     <arithOp> + <relation>
    #   | <arithOp> - <relation>
    #   | <relation>
    #
    def arithmetic_operator
      relation || a_prime
    end

    def a_prime
      if check("operator", "+")
        next!
        if relation
          next!
          a_prime
        end
      elsif check("operator", "-")
        next!
        if relation
          next!
          a_prime
        end
      elsif relation
        next!
        return true
      else
        error("arithmetic operator")
      end
    end


    # <relation> ::=
    #     <relation> < <term>
    #   | <relation> >= <term>
    #   | <relation> <= <term>
    #   | <relation> > <term>
    #   | <relation> == <term>
    #   | <relation> != <term>
    #   | <term>
    #
    def relation
      term || r_prime
    end

    def r_prime
      if check("operator", "<")
        next!
        if term
          next!
          r_prime
        end
      elsif check("operator", "<=")
        next!
        if term
          next!
          r_prime
        end
      elsif check("operator", ">=")
        next!
        if term
          next!
          r_prime
        end
      elsif check("operator", ">")
        next!
        if term
          next!
          r_prime
        end
      elsif check("operator", "==")
        next!
        if term
          next!
          r_prime
        end
      elsif check("operator", "!=")
        next!
        if term
          next!
          r_prime
        end
      elsif term
        next!
        return true
      else
        error("relation")
      end
    end

    # <term> ::= 
    #     <term> * <factor>
    #   | <term> / <factor>
    #   | <factor>
    #
    def term
      factor || t_prime
    end

    def t_prime
      if check("operator", "*")
        next!
        if factor
          next!
          t_prime
        end
      elsif check("operator", "/")
        next!
        if factor
          next!
          t_prime
        end
      elsif factor
        next!
        return true
      else
        error("term")
      end
    end


    # <factor> ::= 
    #     ( <expression> ) 
    #   | [ - ] <name> 
    #   | [ - ] <number> 
    #   | <string>
    #   | true
    #   | false
    #
    def factor
      if check("left_paren", "(")
        next!
        if expression
          next!
          check("right_paren", ")")
        end
      elsif check("operator", "-")
        next!
        if name || number
          next!
          return true
        end
      elsif string
        next!
        return true
      elsif check("keyword", "true") || check("keyword", "false")
        next!
        return true
      elsif name || number
        next!
        return true
      else
        error("symbol")
        return false
      end
    end


    # <name> ::= 
    #   <identifier> [ [ <expression> ] ]
    #
    def name
      if identifier
        next!     
        return true
      else
        error("identifier")
      end
    end


    # <number> ::= [0-9][0-9_]*[.[0-9_]*]
    #
    def number
      return !(@next['lexeme'].match(/[0-9][0-9_]*[.[0-9_]*]?/)).nil?
    end


    # <string> :: = “[a-zA-Z0-9 _,;:.']*”
    #
    def string
      unless check("whitespace", "EOF")
        return !(@next['lexeme'].match(/\"[a-zA-Z0-9 _,;:.']*\"/)).nil?
      else
        return false
      end
    end


    # <if_statement> ::=
    #   if ( <expression> ) then ( <statement> ; )+
    #   [ else ( <statement> ; )+ ]
    #   end if
    #
    def if_statement    
      if check("keyword", "if")
        next!
        if check("left_paren", "(")
          next!
          if expression
            if check("right_paren", ")")            
              next!
              if check("keyword", "then")              
                next!
                until !statement || check("keyword", "else") || check("keyword", "end")
                  next!
                end
                if check("keyword", "else")
                  next!
                  until !statement || check("keyword", "else")
                    next!
                  end 
                else
                  error("keyword else")
                end

                if check("keyword", "end")
                  next!
                  if check("keyword", "if")
                    return true
                  else
                    error("keyword if")
                  end
                else
                  error("keyword end")
                end 
              else
                error("keyword then")
              end
            else
              error("right paren")
            end
          else
            error("expression")
          end
        else
          error("left paren")
        end
      else
        error("keyword if")
      end
    end


    # <loop_statement> ::=
    #   for ( <assignment_statement> ; 
    #     <expression> ) 
    #     ( <statement> ; )*
    #   end for
    #
    def loop_statement
      if check("keyword", "for")
        next!
        if check("left_paren", "(")
          next!
          if assignment_statement
            next!
            if expression
              if check("right_paren", ")")
                next!
                until !statement || check("keyword", "end")
                  next!
                end
                if check("keyword", "end")
                  next!
                  if check("keyword", "for")
                    return true
                  else
                    error("keyword for")
                  end
                else
                  error("keyword end")
                end
              else
                error("right paren")
              end
            else
              error("expression")
            end
          else
            error("assignment statement")
          end
        else
          error("left paren")
        end
      else
        error("keyword for")
      end
    end


    # <return_statement> ::= return
    #
    def return_statement 
      if check("keyword", "return")
        return true
      else
        error("keyword return")
      end
    end


    # <procedure_call> ::=
    #   <identifier> ( [<argument_list>] )
    #
    def procedure_call
      if identifier
        next!
        if check("left_paren", "(")
          next!
          if argument_list
            next!
            if check("right_paren", ")")
              return true
            else
              error("right paren")
            end
          else
            error("argument list")
          end
        else
          error("left paren")
        end
      else
        error("identifier")
      end
    end


    # <argument_list> ::=
    #     <expression> , <argument_list>
    #   | <expression>
    #
    def argument_list
      if expression
        next!
        if check("comma", ",")
          next!
          if argument_list
            return true
          else
            error("argument list")
          end
        else
          return true
        end
      else
        error(expression)
      end
    end
end