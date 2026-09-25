// § tpAnonStructLastParamUser167
module m1 (input logic a, output logic [7:0] b);
  localparam type it_t = struct packed { logic [7:0] x; logic [7:0] y; };
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  assign b = a ? I.x : I.y;
endmodule
module m2 (input logic a, output logic [3:0] b);
  localparam type it_t = struct packed { logic [3:0] x; logic [3:0] y; };
  localparam it_t I = '{x: 4'd1, y: 4'd2};
  assign b = a ? I.x : I.y;
endmodule
module top (input logic a, output logic [7:0] b, output logic [3:0] c);
  m1 u1 (.a(a), .b(b));
  m2 u2 (.a(a), .b(c));
endmodule
