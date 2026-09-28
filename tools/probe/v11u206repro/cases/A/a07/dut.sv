// § tpCastUseBindsDefDefault206
module c #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = s ? t'(1) : t'(0);
  end
  assign o = x[0] | x[1];
endmodule
module a07 (input logic s, output logic [1:0] o1, output logic [1:0] o2);
  c u1 (.s(s), .o(o1));
  c u2 (.s(~s), .o(o2));
endmodule
