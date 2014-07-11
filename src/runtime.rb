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

class Runtime
  def load_runtime_symbol_table
    {
      "getbool" => {name: "getbool", type: "procedure"},
      "getinteger" =>{name: "getinteger", type: "procedure"},
      "getfloat" => {name: "getfloat", type: "procedure"},
      "getstring" => {name: "getstring", type: "procedure"},
      "putbool" => {name: "putbool", type: "procedure"},
      "putinteger" => {name: "putinteger", type: "procedure"},
      "putfloat" => {name: "putfloat", type: "procedure"},
      "putstring" => {name: "putstring", type: "procedure"},
    }
  end

  def load_runtime_code_generation
    '
getBool:
  scanf("%s", &R[0]);

getInteger:
  scanf("%s", &R[0]);

getFloat:
  scanf("%s", &R[0]);

getString:
  scanf("%s", &R[0]);

putBool:
  printf("%s", R[0]);

putInteger:
  printf("%s", R[0]);

putFloat:
  printf("%s", R[0]);

putString:
  printf("%s", R[0]);
'
  end
end