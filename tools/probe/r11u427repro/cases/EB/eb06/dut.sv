// § elabBasedLitLowerBase427
package p;
  parameter B = 4'B10x1;
  parameter H = 'HFF;
endpackage
module top(input logic [7:0] a, output logic [7:0] o);
  import p::*;
  localparam L = 4'B1z01;
  assign o = a ^ {4'b0, B} ^ H;
endmodule
