// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter logic [3:0] B = 4'b1x;
endpackage
module top(output [3:0] o);
  assign o = p::B;
endmodule
