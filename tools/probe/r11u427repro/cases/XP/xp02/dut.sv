// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'B10x1;
  parameter H = 8'hxF;
  parameter Z = 'bz;
  parameter logic [3:0] L = 4'b1x0z;
endpackage
module top(input logic [7:0] a, output logic [7:0] o, output logic [7:0] q, output logic [7:0] r);
  import p::*;
  assign o = a ^ {4'b0, B};
  assign q = a & H;
  assign r = a | {4'b0, L};
endmodule
