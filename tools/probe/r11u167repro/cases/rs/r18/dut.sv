// § tpAnonStructLastParamUser167
module sub #(parameter type it_t = struct packed { logic [7:0] x; logic [7:0] y; })
  (input logic a, output logic [7:0] b);
  localparam it_t I = '{x: 1, y: 2};
  assign b = a ? I.x : I.y;
endmodule
module top (input logic a, output logic [7:0] b, output logic [7:0] c);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } t2_t;
  sub u1 (.a(a), .b(b));
  sub #(.it_t(t2_t)) u2 (.a(a), .b(c));
endmodule
