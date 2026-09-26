// § patFlatMemberLeftSpan169
module top (input logic a, output logic [15:0] b);
  sub #(.W(16), .A(5)) u (.a(a), .b(b));
endmodule
module sub #(parameter int W = 8, parameter int A = 3) (input logic a, output logic [W-1:0] b);
  typedef struct packed { logic [W-1:0] x; logic [W-1:0] y; } it_t;
  localparam it_t I = '{x: (A << 2) | 1, y: -A};
  assign b = a ? I.x : I.y;
endmodule
