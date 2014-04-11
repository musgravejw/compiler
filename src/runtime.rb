#!/usr/bin/ruby

# runtime.rb
# John Musgrave
# Abstract:  enters the runtime function names and type signatures into the symbol table prior to starting the parse of the input files
# 	supports the following functions:
# 	  bool getBool()
# 	  integer getInteger()
# 	  string getFloat()
# 	  string getString()
# 	  integer putBool(bool)
# 	  integer putInteger(integer)
# 	  integer putFloat(float)
# 	  integer putString(string)

def class Runtime
  def load_runtime
    {
      getBool: {name: "getBool", type: "bool"},
      getInteger: {name: "getInteger", type: "integer"},
      getFloat: {name: "getFloat", type: "string"},
      getString: {name: "getString", type: "string"},
      putBool: {name: "putBool", type: "integer"},
      putInteger: {name: "putInteger", type: "integer"},
      putFloat: {name: "putFloat", type: "integer"},
      putString: {name: "putString", type: "integer"},
    }
  end
end