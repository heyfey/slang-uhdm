// § tpArrayElemBindsDefDefault206
module b04 #(parameter int W = 3, parameter type t = logic [W-1:0]) (input logic clk, input t i, output t o);
  t m [4];
  t [1:0] p;
  always_ff @(posedge clk) begin m[0] <= i; p[0] <= m[0]; end
  assign o = p[0];
endmodule
