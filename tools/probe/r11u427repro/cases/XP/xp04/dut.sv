// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b10x1;
  parameter logic X1 = 1'bx;
endpackage
module top(input logic clk, input logic [3:0] a, output logic [3:0] o);
  import p::*;
  always_ff @(posedge clk) o <= a ^ B;
  initial begin
    if (a == B) o = 4'b0;
  end
endmodule
