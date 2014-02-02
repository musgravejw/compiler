# parser.rb
# LL(1) Recursive Descent parser

require './scanner.rb'

class Parser
  @next = ""

  def initialize(filename)  	
    @scanner = Scanner.new(filename)
    @next = @scanner.get_next_token()
  end

  def start
    return program_header() && program_body()
  end

  private
    def program_header
      # program && identifier() && is
    end

    def program_body
      # (statement;)*
      return declaration() && begin_program() && statement() && end_program()
    end

    def declaration
      # global && procedure_declaration
      return procedure_declaration() || variable_declaration()
    end

    def procedure_declaration
      return procedure_header() && procedure_body()
    end

    def procedure_header
      return procedure() && indentifier() && parameter_list()
    end

    def parameter_list
      # parameter , parameter_list() ||
      return parameter()
    end

    def parameter
      # in | out
      return variable_declaration()
    end

    def procedure_body
      # declaration
    end

    def variable_declaration
      # array_size()
      return type_mark() && identifier()
    end

    def type_mark
      return integer() || float() || bool() || string()
    end

    def array_size
      return number()
    end

    def statement
      return assignment_statement() || if_statement() || loop_statement() || return_statement() || procedure_call()
    end

    def procedure_call
      # identifier (argument_list)
      return identifier()
    end

    def assigment_statement
      # string literal :=
      return destination() && expression()
    end

    def destination
      return identifier() 
    end

    def if_statement      
    end

    def loop_statement
    end

    def return_statement
    end

    def identifier
      result =!(@next[/[a-zA-Z][a-zA-Z0-9_]*/]).nil?
      increment()
      return result
    end

    def expression
    end

    def arithmetic_operator
    end

    def relational_operator
      result = false
      if relation() && term()
        result = true
      end
      return result
    end

    def term
      result = false
      if term() && factor()
        result = true
      end
      return result
    end

    def factor
    end

    def name
      return identifier() && expression()
    end

    def argument_list
    end

    def number(str)
      return !(str[/[0-9][0-9_]*[.[0-9_]*]/]).nil?
    end

    def string(str)
      return !(str[/"[a-zA-Z0-9_,;:.']*"/]).nil?
    end

    def increment
      @next = @scanner.get_next_token()
    end

    def program
      result = @next.lexeme == "program"
      increment()
      return result
    end

    def is
      rresult = @next.lexeme == "is"
      increment()
      return result
    end

    def begin_program
      result = @next.lexeme == "begin"
      increment()
      return result
    end

    def end_program
      result = @next.lexeme == "end program"
      increment()
      return result
    end

    def procedure
      result = @next.lexeme == "procedure"
      increment()
      return result
    end
end
