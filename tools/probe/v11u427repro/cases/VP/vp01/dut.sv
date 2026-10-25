// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter logic BX = 1'bx;
endpackage
module top(output [7:0] o);
  assign o = p::BX;
endmodule
