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
  end

  def check(token_class, lexeme)
    return (token_class == @next['class'] && lexeme == @next['lexeme'])    
  end

  def resync(token_class, lexeme)
    until check(token_class, lexeme)
      next!
    end
  end

  def error(str, type = "Parse")
    if type == "Type"
      puts "=> Warning: Type mismatch [line #{@scanner.line}, col #{@scanner.col}]:  expected #{str}"
    elsif type == "Undefined"
      puts "=> Variable undefined [line #{@scanner.line}, col #{@scanner.col}]:  #{str}"
    else      
      puts "=> #{type} error [line #{@scanner.line}, col #{@scanner.col}]:  invalid symbol \"#{@next['lexeme']}\" expected '#{str}'."
    end
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
          @generator.output()
          puts "=> Parse completed successfully."
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
          error("semi colon")
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
          symbol = @symbol_table.find_symbol(@name)
          if symbol.nil?
            @symbol_table.add_symbol({
              name: @name,
              type: @type
            })
          end
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
            return true
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
      if @type = type_mark
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
        p = @next["lexeme"]
        if identifier
          @generator.gen("\n#{p}:")
          next!
          if check("left_paren", "(")
            next!
            if check("right_paren", ")")
              @symbol_table.enter_scope 
              return true
            else
              @symbol_table.enter_scope
              if parameter_list
                if check("right_paren", ")")                
                  return true
                else
                  error("right paren")
                end
              else
                error("parameter list")
              end
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
      @generator.indent()
      while program_declaration
        next!
      end
      @generator.outdent()
      if check("keyword", "begin")
        next!
        @generator.indent()
        while program_statement
          next!
        end
        @generator.outdent()
        @generator.gen("")
        if check("keyword", "end")
          next!
          if check("keyword", "procedure")
            next!
            @symbol_table.exit_scope
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
        return @type
      elsif check("keyword", "float") 
        @type = "float"
        return @type
      elsif check("keyword", "bool") 
        @type = "bool"
        return @type
      elsif check("keyword", "string")
        @type = "string"
        return @type
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
      dest = @next["lexeme"]
      if d = destination
        if @symbol_table.find_symbol(dest)
          if check("colon_equals", ":=")
            next!
            value = @next["lexeme"]
            token_class = @next["class"]
            if e = expression
              symbol = @symbol_table.find_symbol(dest)

              if token_class == "identifier"
                var_symbol = @symbol_table.find_symbol(value)
                symbol[:value] = var_symbol[:value]
                @generator.load(var_symbol[:address])
              else
                symbol[:value] = value
                @generator.mem(symbol[:address], symbol[:value])
                @generator.load(symbol[:address])
              end

              if d == e
                @symbol_table.add_symbol(symbol)
                address = @symbol_table.find_symbol(symbol[:name])[:address]
                @generator.store(address)
                return true
              else
                error("#{d}, got #{e}.", "Type")
                return true
              end
            else
              error("expression")
            end
          else
            error("colon equals")
          end
        else
          error(dest, "Undefined")
        end
      else
        error("destination")
      end
    end


    # <destination> ::= 
    #   <identifier> [ [ <expression> ] ]
    #
    def destination
      name = @next["lexeme"]
      if identifier
        next!        
        if check("left_bracket", "[")
          next!
          name = @next["lexeme"]
          if e = expression            
            if check("right_bracket", "]")
              next!
              symbol = @symbol_table.find_symbol(name)
              symbol[:type] = e
              @symbol_table.update_symbol(symbol)
              return e
            else
              error("right bracket")
            end
          else
            error("expression")
          end
        else
          return @symbol_table.find_symbol(name)[:type]
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
          return t
        end
      elsif check("operator", "|")
        @operation = "|"
        next!
        type = arithmetic_operator
        if type
          next!
          t = e_prime
          return t
        end
      elsif check("keyword", "not")
        next!
        type = arithmetic_operator
        if type
          next!
          t = e_prime
          return t
        end
      else
        type = arithmetic_operator
        if type
          next!
          t = e_prime
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
      current = @next["lexeme"]
      unless  @symbol_table.find_symbol(current).nil?
        address = @symbol_table.find_symbol(current)[:address]
        value = @symbol_table.find_symbol(current)[:value]
      end
      type = relation      
      type ||= a_prime
      if @next["class"] == "operator"
        t = a_prime
        if type == t
          @generator.op(@operation)
        else
          error("#{type} got #{t}", "Type mismatch")
        end
        return t
      else
        @generator.op(@operation)
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
      elsif !@next["class"] == "keyword"
        if t = relation
          next!
          return t
        end
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
          return t
        end
      elsif check("operator", "/")
        @operation = "/"
        next!
        type = factor
        if type
          next!
          t = t_prime(type)
          return t
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
        unless @symbol_table.find_symbol(@next['lexeme']).nil?
          address = @symbol_table.find_symbol(@next['lexeme'])[:address]
          value = @symbol_table.find_symbol(@next['lexeme'])[:value]
        end
        return type
      elsif string
        unless @symbol_table.find_symbol(@next['lexeme']).nil?
          address = @symbol_table.find_symbol(@next['lexeme'])[:address]
          value = @symbol_table.find_symbol(@next['lexeme'])[:value]
        end
        next!
        return 'string'
      elsif check("keyword", "true")
        unless @symbol_table.find_symbol(@next['lexeme']).nil?
          address = @symbol_table.find_symbol(@next['lexeme'])[:address]
          value = @symbol_table.find_symbol(@next['lexeme'])[:value]
        end
        next!
        return 'bool'
      elsif check("keyword", "false")
        unless @symbol_table.find_symbol(@next['lexeme']).nil?
          address = @symbol_table.find_symbol(@next['lexeme'])[:address]
          value = @symbol_table.find_symbol(@next['lexeme'])[:value]
        end
        next!
        return 'bool'      
      else
        current = @next['lexeme']
        type = name
        type ||= number
        unless @symbol_table.find_symbol(current).nil?
          address = @symbol_table.find_symbol(current)[:address]
          value = @symbol_table.find_symbol(current)[:value]
        end
        return type
      end
    end


    # <name> ::= 
    #   <identifier> [ [ <expression> ] ]
    #
    def name
      name = @next["lexeme"]
      if identifier
        next!
        if check("left_bracket", "[")
          next!
          if expression
            if check("right_bracket", "]")
              next!
              return @symbol_table.find_symbol(name)[:type]
            else
              error("right bracket")
            end
          else
            error("array size")
          end       
        else
          return @symbol_table.find_symbol(name)[:type]  
        end
      else
        #error("identifier")
      end
    end


    # <number> ::= [0-9][0-9_]*[.[0-9_]*]
    #
    def number
      number = @next["class"]
      result = !(@next['lexeme'].match(/[0-9][0-9_]*[.[0-9_]*]?/)).nil?      
      next!
      if result
        return number
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
                until check("keyword", "else") || check("keyword", "end") || !program_statement
                  next!
                end
                if check("keyword", "else")
                  next!
                  until !program_statement
                    next!
                  end
                end
                next!
                if check("keyword", "if")
                  next!                    
                  return true
                else
                  error("keyword end if")
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
          @symbol_table.enter_scope
          @generator.gen(@generator.margin + "label here:")
          @generator.indent()
          if assignment_statement
            if check("semi_colon", ";")
              next!
              if expression
                if check("right_paren", ")")                  
                  next!
                  until !program_statement
                    next!
                  end
                  if check("keyword", "end")
                    next!
                    if check("keyword", "for")
                      # jcnd here
                      @generator.outdent()
                      @symbol_table.exit_scope
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
        next!
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
        if p = @symbol_table.find_symbol(@next["lexeme"])
          next!
          if check("left_paren", "(")
            next!
            if check("right_paren", ")")
              next!
              return true
            else
              if argument_list
                if check("right_paren", ")")
                  next!
                  @generator.gen(@generator.margin + "goto " + p[:name] + ";")
                  return true
                else
                  error("right paren")
                end
              end
            end            
          else
            error("left paren")
          end
        else
          error("procedure call", "Symbol")
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
          return argument_list
        else
          return true
        end
      else
        error("expression")
      end
    end
end