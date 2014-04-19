#!/usr/bin/ruby

# parser.rb
# John Musgrave
# Abstract:  LL(1) Recursive Descent parser
#   Uses scanner to build the parse table
#   Incorporates type checking
#   Grammar requirements for each method are stated in BNF notaion above

dir = File.dirname(__FILE__)
require "#{dir}/scanner.rb"
require "#{dir}/semantic.rb"
require "#{dir}/code_gen.rb"

class Parser
  def initialize(filename)
    @scanner = Scanner.new(filename) 
    @next = {}
    @name = ""
    @type = ""
    @operation = ""
    @symbol_table = SymbolTable.new
    @generator = CodeGen.new
  end

  def next!
    @next = @scanner.get_next_token 
    abort if @next['lexeme'] == "EOF"
    #puts @next
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
    puts "=> Parse error [line #{@scanner.line}, col #{@scanner.col}]:  invalid symbol \"#{@next['lexeme']}\" expected '#{str}'."
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
        @type = "program"     
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
      while program_declaration
        next!
      end
      @symbol_table.enter_scope
      if check("keyword", "begin")
        next!
        while program_statement
          next!
        end
        if check("keyword", "end")
          next!
          if check("keyword", "program")
            @symbol_table.exit_scope
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
        #next!        
        if check("semi_colon", ";")
          return true
        else
          error("semi colon")
        end
      else 
        return false
      end
    end

    def program_statement
      if statement
        if check("semi_colon", ";")
          return true
        else
          #error("semi colon")
        end
      else
        return false
      end
    end


    # <identifier> ::= [a-zA-Z][a-zA-Z0-9_]*
    #
    def identifier
      unless check("whitespace", "EOF")
        unless (@next['lexeme'].match(/[a-zA-Z][a-zA-Z0-9_]*/)).nil?
          @name = @next["lexeme"]
          @symbol_table.add_symbol({
            name: @name,
            type: @type
          })
          # puts "\n" + @symbol_table.inspect + "\n\n"
          return true
        end
      else
        return false
      end   
    end


    # <declaration> ::=
    #   [ global ] <procedure_declaration>
    #   | [ global ] <variable_declaration>
    #
    def declaration
      if check("keyword", "global")
        next!
        return procedure_declaration || variable_declaration  
      else
        return procedure_declaration || variable_declaration
      end
    end


    # <statement> ::=
    #     <assignment_statement>
    #   | <if_statement>
    #   | <loop_statement>
    #   | <return_statement>
    #   | <procedure_call>
    #
    def statement
      @symbol_table.enter_scope
      if first("assignment")
        assignment_statement   
      elsif first("if")
        if_statement
      elsif first("loop")
        loop_statement
      elsif first("return")
        return_statement
      elsif first("procedure")
        procedure_call
      end
      @symbol_table.exit_scope
    end

    def first(alpha)      
      if alpha == "assignment"
        symbol = @symbol_table.find_symbol(@next["lexeme"])
        if symbol
          unless symbol[:type] == "procedure"
            identifier
          end
        end
      elsif alpha == "if"        
        check("keyword", "if")
      elsif alpha == "loop"
        check("keyword", "for")
      elsif alpha == "return"
        check("keyword", "return")
      elsif alpha == "procedure"
        unless @next["class"] == "keyword"
          symbol = @symbol_table.find_symbol(@next["lexeme"])
          symbol ||= {}
          if symbol[:type] == "procedure"
            procedure_call            
          end
        end
      end
    end


    # <procedure_declaration> ::= 
    #   <procedure_header> <procedure_body>
    #
    def procedure_declaration
      if procedure_header
        next!
        procedure_body
      else
        #error("procedure header")
      end
    end


    # <variable_declaration> ::=
    #   <type_mark> <identifier> 
    #   [ [ <array_size> ] ]
    #
    def variable_declaration
      @type = "variable"
      if type_mark
        next!
        if identifier
          next!          
          if check("left_bracket", "[")
            next!
            if array_size
              if check("right_bracket", "]")
                next!
                return true
              else
                error("right bracket")
              end
            else
              error("array size")
            end       
          else
            return true   
          end
        else
          error("identifier")
        end
      else
        #error("type mark")
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
        @type = "procedure"
        if identifier
          next!
          if check("left_paren", "(")
            next!
            if parameter_list
              #next!
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
        #error("keyword procedure")
      end
    end


    # <procedure_body> ::= 
    #     ( <declaration> ; )*
    #   begin
    #     ( <statement> ; )*
    #   end procedure
    # 
    def procedure_body
      while program_declaration
        next!
      end      
      if check("keyword", "begin")
        next!
        while program_statement
          next!
        end
        if check("keyword", "end")
          next!
          if check("keyword", "procedure")
            next!
            return true
          else
            error("keyword procedure")
          end
        else
          error("keyword end")
        end      
      else
        error("keyword begin")
      end
    end


    # <type_mark> ::=
    #     integer
    #   | float
    #   | bool
    #   | string
    #
    def type_mark
      if check("keyword", "int") || check("keyword", "integer")
        @type = "integer"
        return true
      elsif check("keyword", "float") 
        @type = "float"
        return true
      elsif check("keyword", "bool") 
        @type = "bool"
        return true
      elsif check("keyword", "string")
        @type = "string"
        return true
      end
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
        if check("keyword", "in") || check("keyword", "out")
          return true
        else
          error("in || out")
        end
      else
        error("variable declaration")
      end
    end


    # <assignment_statement> ::=
    #   <destination> := <expression>
    #
    def assignment_statement
      if destination
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
    #   <identifier> [ [ <expression> ] ]
    #
    def destination
      if identifier
        next!        
        if check("left_bracket", "[")
          next!
          if expression
            if check("right_bracket", "]")
              next!
              return true
            else
              error("right bracket")
            end
          else
            error("expression")
          end
        else
          return true
        end
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
        @operation = "&"
        next!
        type = arithmetic_operator
        if type
          next!
          t = e_prime
          @generator.op(type, t, @operation)
          return t
        end
      elsif check("operator", "|")
        @operation = "|"
        next!
        type = arithmetic_operator
        if type
          next!
          t = e_prime
          @generator.op(type, t, @operation)
          return t
        end
      elsif check("keyword", "not")
        next!
        type = arithmetic_operator
        if type
          next!
          t = e_prime
          @generator.op(type, t, @operation)
          return t
        end
      else
        type = arithmetic_operator
        if type
          next!
          t = e_prime
          @generator.op(type, t, @operation)
          return t
        end
      end
    end


    # <arithOp> ::=
    #     <arithOp> + <relation>
    #   | <arithOp> - <relation>
    #   | <relation>
    #
    def arithmetic_operator
      type = relation
      type ||= a_prime
      if @next["class"] == "operator"
        t = a_prime
        @generator.op(type, t, @operation)
        return t
      else
        return type
      end
    end

    def a_prime
      if check("operator", "+")
        @operation = "+"
        next!
        relation
      elsif check("operator", "-")
        @operation = "-"
        next!
        relation
      elsif !@next["class"] == "keyword" && relation
        next!
        return true
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
      type = term
      type ||= r_prime
      if @next["class"] == "operator"
        t = r_prime
        @generator.op(type, t, @operation)
        return t
      else
        return type
      end
    end

    def r_prime
      if check("operator", "<")
        @operation = "<"
        next!
        term
      elsif check("operator", "<=")
        @operation = "<="
        next!
        term
      elsif check("operator", ">=")
        @operation = ">="
        next!
        term
      elsif check("operator", ">")
        @operation = ">"
        next!
        term
      elsif check("operator", "==")
        @operation = "=="
        next!
        term
      elsif check("operator", "!=")
        @operation = "!="
        next!
        term
      else
        term
      end
    end


    # <term> ::= 
    #     <term> * <factor>
    #   | <term> / <factor>
    #   | <factor>
    #
    def term
      type = factor
      if type
        return type
      else
        t_prime("")
      end
    end

    def t_prime(type)
      type = ""
      if check("operator", "*")
        @operation = "*"
        next!
        type = factor
        if type
          next!
          t = t_prime(type)
          @generator.op(type, t, @operation)
        end
      elsif check("operator", "/")
        @operation = "/"
        next!
        type = factor
        if type
          next!
          t = t_prime(type)
          @generator.op(type, t, @operation)
        end
      else
        type = factor
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
      current = @next['lexeme']
      if check("left_paren", "(")
        next!
        type = expression
        if type
          next!
          check("right_paren", ")")
          return type
        end
      elsif check("operator", "-")
        next!
        current = @next['lexeme']
        type = name
        type ||= number
        @generator.gen("R[" + @generator.reg.to_s + "] = " + current)
        return type
      elsif string
        @generator.gen("R[" + @generator.reg.to_s + "] = " + current)
        next!
        return 'string'
      elsif check("keyword", "true")
        @generator.gen("R[" + @generator.reg.to_s + "] = 1")
        next!
        return 'bool'
      elsif check("keyword", "false")
        @generator.gen("R[" + @generator.reg.to_s + "] = 0")
        next!
        return 'bool'      
      else
        current = @next['lexeme']
        type = name
        type ||= number
        @generator.gen("R[" + @generator.reg.to_s + "] = " + current)
        return type
      end
    end


    # <name> ::= 
    #   <identifier> [ [ <expression> ] ]
    #
    def name
      if identifier
        next!
        if check("left_bracket", "[")
          next!
          if expression
            if check("right_bracket", "]")
              next!
              return 'name'
            else
              error("right bracket")
            end
          else
            error("array size")
          end       
        else
          return 'name'   
        end
      else
        #error("identifier")
      end
    end


    # <number> ::= [0-9][0-9_]*[.[0-9_]*]
    #
    def number
      result = !(@next['lexeme'].match(/[0-9][0-9_]*[.[0-9_]*]?/)).nil?
      next!
      if result
        return 'number'
      end
    end


    # <string> :: = “[a-zA-Z0-9 _,;:.']*”
    #
    def string
      unless check("whitespace", "EOF")
        return !(@next['lexeme'].match(/"[a-zA-Z0-9 _,;:.']*"/)).nil?
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
                until check("keyword", "else") || check("keyword", "end") || !statement
                  next!
                end
                if check("keyword", "else")
                  next!
                  until !statement
                    next!
                  end                 
                end
                if check("keyword", "end")
                  next!
                  if check("keyword", "if")                    
                    next!
                    return true
                  else
                    error("keyword end if")
                  end
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
            if check("semi_colon", ";")
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
                      next!
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
              error("semi colon")
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
            if check("right_paren", ")")
              next!
              return true
            else
              error("right paren")
            end
          else
            if check("right_paren", ")")
              next!
              return true
            else
              error("right paren")
            end
          end
        else
          error("left paren")
        end
      end
    end


    # <argument_list> ::=
    #     <expression> , <argument_list>
    #   | <expression>
    #
    def argument_list
      if expression
        if check("comma", ",")
          next!
          argument_list
        else
          return true
        end
      else
        error("expression")
      end
    end
end