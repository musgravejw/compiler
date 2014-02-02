# parser.rb
# LL(1) Recursive Descent parser

class Parser

  def start(str)
    return program_header() && program_body()
  end

  private
    def program_header(str)
      # program && identifier() && is
    end

    def program_body(str)
      # declaration

      # statement
    end

    def declaration(str)
      # global && procedure_declaration
      return procedure_declaration() || variable_declaration()
    end

    def procedure_declaration(str)
      return procedure_header() && procedure_body()
    end

    def procedure_header(str)
      # procedure indentifier() parameter_list
    end

    def parameter_list(str)
      # parameter , parameter_list()    	
      return parameter()
    end

    def parameter(str)
      # in | out
      return variable_declaration()
    end

    def procedure_body(str)
      # declaration
    end

    def variable_declaration(str)
      # array_size()
      return type_mark() && identifier()
    end

    def type_mark(str)
      return integer() || float() || bool() || string()
    end

    def array_size(str)
      return number()
    end

    def statement(str)
      return assignment_statement() || if_statement() || loop_statement() || return_statement() || procedure_call()
    end

    def procedure_call(str)
      
    end

end
