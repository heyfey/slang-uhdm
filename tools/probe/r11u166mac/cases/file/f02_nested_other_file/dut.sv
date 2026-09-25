// § ppOutputFile166
`include "a.svh"
`include "b.svh"
module top(input clk);
  always @(posedge clk) begin
    `OUT(chk)
  end
endmodule
