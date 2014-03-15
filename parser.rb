# parser.rb
# Abstract:  LL(1) Recursive Descent parser
#   Uses scanner to build abstract syntax tree
#   Grammar requirements for each method are stated in BNF notaion above

require './scanner.rb'

class Parser  
  def initialize(filename)
    @next = {}
    @scanner = Scanner.new(filename)    
  end

  def next!
    @next = @scanner.get_next_token
    puts @next
  end

  def check(token_class, lexeme)
    return (token_class == @next['class'] && lexeme == @next['lexeme'])    
  end

  def error(str)
    puts "=> Parse error [line #{@scanner.line}, col #{@scanner.col}]:  \"invalid #{str}\" for token '#{@next['lexeme']}'."
  end

  def start
    next!
    return program
  end
  
  def program    
    result = program_header
    if result == true
      next!
      result = program_body
      if result == true
        puts "Parse completed successfully."
      end
    end
  end

  def program_header    
    if check("keyword", "program")     
      next! 
      if identifier
        next!
        check("keyword", "is")
      end
    end    
  end

  def program_body
    if program_declaration            
      next!
      if check("keyword", "begin")
        next!
        if program_statement
          next!
          if check("keyword", "end")
            next!
            check("keyword", "program")            
          end
        end        
      end
    end
  end

  def program_declaration
    # handle Kleene *    
    if declaration
      next!
      check("semi_colon", ";")
    end
  end

  def program_statement
    # handle Kleene *
    if statement
      next!
      check("semi_colon", ";")
    end
  end

  def identifier    
    return !(@next['lexeme'].match(/[a-zA-Z][a-zA-Z0-9_]*/)).nil?    
  end

  def declaration
    # check for global    
    return procedure_declaration || variable_declaration
  end

  def statement            
    return true
    # return assignment_statement || if_statement || loop_statement || return_statement || procedure_call
  end

  def procedure_declaration    
    result = procedure_header 
    if result == true
      next!
      procedure_body
    end
  end

  def variable_declaration    
    if type_mark
      next!
      identifier      
      # check for brackets
    end
  end

  def procedure_header    
    if check("keyword", "procedure")
      next!
      if identifier
        next!
        if check("left_paren", "(")
          if parameter_list
            next!
            check("right_paren", ")")            
          end
        end
      end
    end
  end

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
          end
        end        
      end
    end
  end

  def type_mark    
    return (check("keyword", "int") || check("keyword", "float") || check("keyword", "bool") || check("keyword", "string"))
  end

  def parameter_list
    next!
    next!
    next!
    return true
  end

  def assignment_statement
    if destination
      next!
      if check("colon_equals", ":=")
        next!
        expression
      end
    end
  end

  def destination
    if identifier
      next!
      return true      
    end
  end

  def expression
    if arithmetic_operator
      next!
      e_prime
    end
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
    else 
      if arithmetic_operator
        next!
        e_prime
      end
    end
  end

  def arithmetic_operator
   if relation
    next!
    a_prime
   end
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
    else
      relation
    end
  end

  def relation
    if term
      next!
      r_prime
    end
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
    else      
     term
    end
  end

  def term
    if factor
      next!
      t_prime
    end
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
    else      
      factor      
    end
  end

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
        return true
      end
    elsif string
      return true
    elsif check("keyword", "true") || check("keyword", "false")
      return true
    end
  end

  def name
    if identifier
      return true
    end
  end

  def if_statement
    if check("keyword", "if")
      next!
      if expression
        next!
        if check("keyword", "then")
          next!
          if statement
            next!
            if check("keyword", "end")
              next!
              check("keyword", "if")
            end
          end
        end
      end
    end
  end

  def loop_statement
    if check("keyword", "for")
      next!
      if check("left_paren", "(")
        next!
        if assignment_statement
          next!
          if check("right_paren", ")")
            next!
            if statement
              next!
              if check("keyword", "end")
                next!
                check("keyword", "for")
              end
            end
          end
        end
      end
    end
  end

  def return_statement 
    check("keyword", "return")
  end

  def procedure_call
    if identifier
      next!
      if check("left_paren", "(")
        next!
        if argument_list
          next!
          check("right_paren", ")")
        end
      end
    end
  end
end