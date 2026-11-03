// § modImpCopyTdChainHomeTop473
// third package c reads PB in a localparam
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
package c;
  import b::*;
  localparam int X = PB + 1;
endpackage
module top(output int y);
  import c::*;
  assign y = X;
endmodule
