// § modImpCopyTdChainHomeTop473
// int-based typedef, negative value
package a;
  typedef int t;
endpackage
package b;
  import a::*;
  parameter t PB = -3;
endpackage
module top(output int y);
  import b::*;
  assign y = PB;
endmodule
