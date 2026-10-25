// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b1x01;
endpackage
module top(output [3:0] o);
  if (p::B == 4'b1x01) begin : g
    assign o = p::B;
  end
endmodule
