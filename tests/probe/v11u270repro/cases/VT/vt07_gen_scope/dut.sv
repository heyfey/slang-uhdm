// § sysCallTimeKwNameSpan270
module top (input clk, output longint o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    always @(posedge clk) o[i] <= $time() + i;
  end
endmodule
