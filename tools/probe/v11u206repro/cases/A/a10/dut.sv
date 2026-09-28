// § tpCastUseBindsDefDefault206
module a10 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic clk, input logic s, output t o);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    always_ff @(posedge clk) x[i] <= s ? t'(x[i] + 1) : t'(x[i] - 1);
  end
  assign o = x[0];
endmodule
