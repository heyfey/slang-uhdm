// § tpArrayElemBindsDefDefault206
module c #(parameter int W = 3, parameter type t = logic [W-1:0]) (input t i, output t o);
  t m [4];
  assign m[1] = i;
  assign o = m[1];
endmodule
module b02 (input logic [2:0] i, output logic [2:0] o, output logic [4:0] o2);
  c u1 (.i(i), .o(o));
  c #(.W(5)) u2 (.i({2'b0, i}), .o(o2));
  c #(.t(logic [2:0])) u3 (.i(i), .o());
endmodule
