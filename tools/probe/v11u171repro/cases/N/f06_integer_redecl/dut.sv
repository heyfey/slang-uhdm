// § splitPortTsKeyOnPortDecl171
module sub (clk, x, y);
   input clk;
   output signed [31:0] x;
   output signed [31:0] y;
   reg signed [31:0] x, y;
   always @(posedge clk) begin x <= 1; y <= 2; end
endmodule
module dut (input clk, output signed [31:0] x, y);
  sub u0 (clk, x, y);
endmodule
