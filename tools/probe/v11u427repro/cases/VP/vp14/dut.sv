// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b1x01;
endpackage
module top(output [3:0] o);
  localparam L = p::B;
  assign o = L;
endmodule
