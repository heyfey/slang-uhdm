// § modImpCopyTdChainHomeTop473
// packed 2-D typedef
package a;
  typedef logic [1:0][3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [7:0] y);
  import b::*;
  assign y = PB;
endmodule
