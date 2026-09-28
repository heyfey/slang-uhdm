// § tpCastUseBindsDefDefault206
module a11 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [3:0] x;
  assign x[3] = s ? t'(1) : t'(2);
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = t'(s) + t'(1);
  end
  assign x[2] = '0;
  assign o = x[0];
endmodule
