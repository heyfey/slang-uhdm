// § patFlatMemberLeftSpan169
module sub #(parameter int A = 3) (input logic a, output logic [7:0] b);
  typedef struct packed { logic [7:0] x; logic [7:0] y; } it_t;
  localparam it_t I = '{x: A <<< 1, y: (A - 1) >> 1};
  assign b = a ? I.x : I.y;
endmodule
module top (input logic a, output logic [7:0] b);
  sub #(.A(5)) s (.a(a), .b(b));
endmodule
