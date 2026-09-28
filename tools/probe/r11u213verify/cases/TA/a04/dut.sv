// § tpArrayElemBindsDefDefault206
module leaf #(parameter int W = 2, parameter type t = logic [W-1:0]) (input t i, output t o);
  t m [3];
  assign m[2] = i;
  assign o = m[2];
endmodule
module a04 (input logic [1:0] i1, input logic [4:0] i2, input logic [1:0] i3, output logic [1:0] o1, output logic [4:0] o2, output logic [2:0] o3);
  leaf u1 (.i(i1), .o(o1));
  leaf #(.t(logic [4:0])) u2 (.i(i2), .o(o2));
  leaf #(.W(3)) u3 (.i({1'b0, i3}), .o(o3));
endmodule
