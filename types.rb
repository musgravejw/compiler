class SymbolTable
  def initialize
  	@table = []
    # @table[0] // global
  	@table << []
  end

  def enter_scope
  	@table << []
  end

  def check_scope
  end

  def add_symbol(symbol)
    @table[-1]
    #[symbol.name] = symbol
  end

  def find_symbol(name)
    @table[-1]
    #[name]
  end

  def exit_scope
  	@table.pop
  end
end