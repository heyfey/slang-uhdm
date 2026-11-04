// § tpAnonStructLastParamUser167
module sub #(parameter type it_t = struct packed { logic [7:0] x; logic [7:0] y; })
  (input logic a, output logic [7:0] b);
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  assign b = a ? I.x : I.y;
endmodule
module top (input logic a, output logic [7:0] b, output logic [7:0] c);
  sub u1 (.a(a), .b(b));
  sub u2 (.a(a), .b(c));
endmodule
