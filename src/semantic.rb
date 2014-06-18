#!/usr/bin/ruby

# semantic.rb
# John Musgrave
# Abstract:  Creates a symbol table for use in scope and type checking

dir = File.dirname(__FILE__)
require "#{dir}/runtime.rb"
require 'pp'

class SymbolTable
  def initialize
    r = Runtime.new
  	@table = []
    @table << r.load_runtime
  	@table << {}
    #@current_address = 16
  end

  def enter_scope
  	@table << {}
    #pp @table
    #puts
  end

  def add_symbol(symbol)
    unless @table[-1].has_key?(symbol[:name]) && !(symbol.has_key?(:value) && !symbol[:value].nil?)
      #symbol[:address] = @current_address
      @table[-1][symbol[:name]] = symbol

      # should have value, address      
      # pp @table
      # puts

      # increment current address
      #@current_address += 16
    end
  end

  def find_symbol(name)
    result = @table[-1][name]
    result ||= @table[1][name]
    result ||= @table[0][name]
    return result
  end

  def exit_scope
  	@table.pop
  end
end