// § importCopyTsInstByRole469
// downstream: a module imports both packages, a typedef'd port width and continuous assignments
package a;
  typedef logic [5:0] t;
  parameter t PA = 6'd17;
  parameter int W = 6;
endpackage
package b;
  import a::*;
  parameter t PB = PA + 6'd1;
endpackage
module top(input logic [5:0] i, output logic [5:0] y, output logic [5:0] z);
  import a::*;
  import b::*;
  assign y = i ^ PA;
  assign z = PB;
endmodule
