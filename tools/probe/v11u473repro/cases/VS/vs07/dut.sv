// § modImpCopyTdChainHomeTop473
// PB read in always_ff and case item
package a;
  typedef logic [3:0] t;
  parameter t PA = 2;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(input logic clk, input logic [3:0] i, output logic [3:0] y);
  import b::*;
  always_ff @(posedge clk)
    case (i)
      PB: y <= PB;
      default: y <= 0;
    endcase
endmodule
