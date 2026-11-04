// § tpAnonStructLastParamUser167
module top #(parameter type it_t = struct packed { logic [7:0] x; logic [7:0] y; })
  (input logic a, output logic [7:0] b);
  assign b = {8{a}};
endmodule
