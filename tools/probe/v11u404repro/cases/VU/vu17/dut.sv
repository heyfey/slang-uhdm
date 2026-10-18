// § undefaultedDefInvalidInst404
module dut #(parameter p) (input clk, input [7:0] d);
  initial begin
    if (p != 8) $fatal(1, "bad p");
  end
  always @(posedge clk) assert (d < p);
endmodule
module top; endmodule
