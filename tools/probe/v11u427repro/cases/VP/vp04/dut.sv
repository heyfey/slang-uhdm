// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 8'hz?;
endpackage
module top(output [7:0] o);
  assign o = p::B & 8'hFF;
endmodule
