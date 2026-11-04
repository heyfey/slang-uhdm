// § tpCastUseBindsDefDefault206
module a06 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t x [4];
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = s ? t'(1) : t'(0);
  end
  assign o = x[0];
endmodule
