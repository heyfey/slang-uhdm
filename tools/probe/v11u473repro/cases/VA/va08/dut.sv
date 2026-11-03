// § modImpCopyTdChainHomeTop473
// class in package c reads PB
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
package c;
  import b::*;
  class K; function int g(); return PB; endfunction endclass
endpackage
module top(output int y);
  import c::*;
  initial begin K k = new; y = k.g(); end
endmodule
