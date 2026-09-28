// § tpCastUseBindsDefDefault206
module c #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    assign x[i] = s ? t'(1) : t'(0);
  end
  assign o = x[0];
endmodule
module p #(parameter type t = logic [1:0]) (input logic s, output t o);
  t [1:0] y;
  c #(.t(t)) u (.s(s), .o(o));
  for (genvar j = 0; j < 2; j++) begin : h
    assign y[j] = s ? t'(2) : t'(1);
  end
endmodule
module a02 (input logic s, output logic [1:0] o);
  p u (.s(s), .o(o));
endmodule
