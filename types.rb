class SymbolTable
  def initialize
  	@table = []
  	@table << {}
  end

  def enter_scope
  	@table << {}
  end

  def check_scope
  end

  def add_symbol
  end

  def find_symbol
  end

  def exit_scope
  	@table.pop
  end
end