// § modImpCopyTdChainHomeTop473
// net declaration assignment reads PB
package a;
  typedef logic [3:0] t;
  parameter t PA = 2;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import b::*;
  wire [3:0] w = PB;
  assign y = w;
endmodule
