// § tpCastUseBindsDefDefault206
package pk; typedef logic [2:0] w_t; endpackage
module a01 #(parameter type t = pk::w_t) (input logic s, output t o);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    always_comb x[i] = s ? t'(1) : t'(0);
  end
  assign o = x[0];
endmodule
