// § tpArrayElemBindsDefDefault206
module c #(parameter int W = 2, parameter type t = logic [W-1:0]) (input t s, output t o);
  t x [4];
  for (genvar i = 0; i < 2; i++) begin : g
    t y [2];
    assign y[0] = s;
    assign x[i] = y[0];
  end
  assign o = x[0];
endmodule
module e16 (input logic [1:0] s, output logic [1:0] o1, output logic [2:0] o2);
  c u1 (.s(s), .o(o1));
  c #(.t(logic [2:0])) u2 (.s({1'b0, s}), .o(o2));
endmodule
