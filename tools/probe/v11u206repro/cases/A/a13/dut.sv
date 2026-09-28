// § tpCastUseBindsDefDefault206
module a13 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    t [1:0] y;
    assign y[0] = s ? t'(i) : t'(3 - i);
    assign x[i] = y[0];
  end
  assign o = x[0];
endmodule
