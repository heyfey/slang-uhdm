// § ppMacroBodyLines160
module top(input logic clk);
  always @(posedge clk) begin
    $display("%0s %0d %0s", `__FILE__, `__LINE__, "z");
  end
endmodule
