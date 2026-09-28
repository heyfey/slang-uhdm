// § tpCastUseBindsDefDefault206
module e09 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t x0, x1;
  for (genvar i = 0; i < 1; i++) begin : g
    assign x0 = s ? t'(1) : t'(0);
  end
  assign o = x0;
endmodule
