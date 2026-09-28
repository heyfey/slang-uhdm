module sub #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [3:0] x;
  assign x[0] = s;
  assign o = x[0];
endmodule
module dut (input logic s, output logic [7:0] o, output logic [1:0] p);
  sub #(.t(logic [7:0])) u (.s(s), .o(o));
  sub v (.s(s), .o(p));
endmodule
