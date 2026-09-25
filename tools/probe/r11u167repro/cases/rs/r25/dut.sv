// § tpAnonStructLastParamUser167
module sub #(parameter type it_t = struct packed { logic [7:0] x; logic [7:0] y; },
             parameter it_t P = '{x: 8'd1, y: 8'd2})
  (input logic a, output logic [7:0] b);
  assign b = a ? P.x : P.y;
endmodule
module top (input logic a, output logic [7:0] b, output logic [7:0] c);
  sub u1 (.a(a), .b(b));
  sub #(.P('{x: 8'd9, y: 8'd9})) u2 (.a(a), .b(c));
endmodule
