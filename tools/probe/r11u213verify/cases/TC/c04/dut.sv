// § tpCastUseBindsDefDefault206
module leaf #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [1:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = s ? t'(i) : t'(~i);
  end
  assign o = x[0];
endmodule
module mid #(parameter type u = logic [2:0]) (input logic s, output u o1, output logic [1:0] o2);
  leaf #(.t(u)) a (.s(s), .o(o1));
  leaf b (.s(~s), .o(o2));
endmodule
module c04 (input logic s, output logic [2:0] p, output logic [5:0] q, output logic [1:0] r, output logic [1:0] z);
  mid m1 (.s(s), .o1(p), .o2(r));
  mid #(.u(logic [5:0])) m2 (.s(s), .o1(q), .o2(z));
endmodule
