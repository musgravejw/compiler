#!/usr/bin/ruby

# code_gen.rb
# John Musgrave
# Abstract
#   Class for code generation

# c := a + b;
# d : = a + c + b;
#
# ;c := a + b;
# R[1] = MM[44]; assumes variable a is at location 44
# R[2] = MM[56];
# R[1] = R[1] + R[2];
# MM[32] = R[1];
# ;d : = a + c + b;
# R[1] = MM[44];
# R[2] = MM[68];
# R[1] = R[1] + R[2];
# MM[44] = R[1];

class CodeGen
  def initialize
  end
end