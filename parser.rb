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
    # abort if check("whitespace", "EOF")
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
    if program_header
      next!
      if program_body
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
        check("keyword", "program")
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
      check("semi_colon", ";")
    end
  end

  def identifier    
    unless check("whitespace", "EOF")
      return !(@next['lexeme'].match(/[a-zA-Z][a-zA-Z0-9_]*/)).nil?    
    else
      return false
    end   
  end

  def declaration
    # check for global    
    return procedure_declaration || variable_declaration
  end

  def statement
    return assignment_statement || if_statement || loop_statement || return_statement || procedure_call
  end

  def procedure_declaration        
    if procedure_header
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
          next!
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
    return check("keyword", "int" || check("keyword", "float") || check("keyword", "bool") || check("keyword", "string"))
  end

  def parameter_list
    if parameter
      next!
      if check("comma", ",")
        next!
        parameter_list
      else
        return true
      end
    end
  end

  def parameter
    if variable_declaration
      next!
      check("keyword", "in") || check("keyword", "in")
    end
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
      return false
    end
  end

  def name
    if identifier
      next!     
      return true
    end
  end

  def number
    return !(@next['lexeme'].match(/[0-9][0-9_]*[.[0-9_]*]?/)).nil?
  end

  def string
    unless check("whitespace", "EOF")
      return !(@next['lexeme'].match(/\"[a-zA-Z0-9 _,;:.']*\"/)).nil?
    else
      return false
    end
  end

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
              end
              if check("keyword", "end")
                next!
                check("keyword", "if")
              end              
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
          if expression
            if check("right_paren", ")")
              next!
              until !statement || check("keyword", "end")
                next!
              end
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