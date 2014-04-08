class SymbolTable
  def initialize
  	@table = []
    # @table[0] // global
  	@table << {}
  end

  def enter_scope
  	@table << {}
  end

  def check_scope
  end

  def add_symbol(symbol)
    unless @table[-1].has_key? symbol[:name]
      @table[-1][symbol[:name]] = symbol
    end
  end

  def find_symbol(name)
    # [-1]?
    @table[0][name]
  end

  def exit_scope
  	@table.pop
  end
end