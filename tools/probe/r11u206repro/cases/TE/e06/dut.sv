// § tpCastUseBindsDefDefault206
module e06 #(parameter type t = struct packed { logic a; logic [1:0] b; }) (input logic s, output t o);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = s ? t'(1) : t'(0);
  end
  assign o = x[0];
endmodule
