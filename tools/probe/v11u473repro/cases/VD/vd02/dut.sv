// § modImpCopyTdChainHomeTop473
// signed bit typedef, negative
package a;
  typedef bit signed [7:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = -5;
endpackage
module top(output logic signed [7:0] y);
  import b::*;
  assign y = PB;
endmodule
