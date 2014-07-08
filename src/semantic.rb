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
    @current_address = 32
  end

  def enter_scope
  	@table << {}
  end

  def add_symbol(symbol)
    unless @table[-1].has_key?(symbol[:name]) && !(symbol.has_key?(:value) && !symbol[:value].nil?)
      symbol[:address] = @current_address
      @table[-1][symbol[:name]] = symbol

      # should the symbol table contain a value? 
      
      # increment current address
      @current_address += 32
    end
  end

  def find_symbol(name)
    result = nil    
    # iterate over the scopes in reverse order, to follow most-closely nested rule
    @table.reverse_each do |scope|
      result = scope[name]
      break if !result.nil?
    end
    return result
  end

  def exit_scope
    @current_address -= @table[-1].size * 32
  	@table.pop
  end
end