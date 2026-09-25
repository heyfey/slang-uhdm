// § nonAnsiArrayNetAtHeader155
module dut(clk, o);
  input clk;
  output reg [3:0] o [2];
  always @(posedge clk) begin o[0] <= 4'd1; o[1] <= 4'd2; end
endmodule
