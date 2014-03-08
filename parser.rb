# parser.rb
# Abstract:  LL(1) Recursive Descent parser
#   Uses scanner to build abstract syntax tree
#   Grammar requirements for each method are stated in BNF notaion above

require './scanner.rb'

class Parser
  @next = {}   

  def initialize(filename)  	
    @scanner = Scanner.new(filename)    
  end

  def next!
    @next = @scanner.get_next_token
  end

  def check(token_class, lexeme)
    return (token_class == @next['class'] && lexeme == @next['lexeme'])    
  end

  def error(str)
    puts "=> Parse error [line #{@scanner.line}, col #{@scanner.col}]:  \"invalid #{str}\" for token '#{@next['lexeme']}'."
  end
  
  def program      
    return program_header && program_body
  end

  def program_header
    next!    
    if check("keyword", "program")      
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
    next!
    return !(@next['lexeme'].match(/[a-zA-Z][a-zA-Z0-9_]*/)).nil?    
  end

  def declaration
    # check for global
    return procedure_declaration || variable_declaration
  end

  def statement
    next!
    next!
    return true
  end

  def procedure_declaration    
    return procedure_header && procedure_body
  end

  def variable_declaration    
    if type_mark      
      identifier      
      # check for brackets
    end
  end

  def procedure_header
    return false
  end

  def procedure_body
    return false
  end

  def type_mark
    next!
    return true
  end
end