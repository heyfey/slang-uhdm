// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter int B = 8'hxx;
endpackage
module top(output [7:0] o);
  assign o = p::B;
endmodule
