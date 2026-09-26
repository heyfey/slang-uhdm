// § patFlatMemberLeftSpan169
`define ONE 8'd1
`define E(v) ((v) + 1) * 2
module top #(parameter int W = 8, parameter int A = 3) (input logic a, output logic [W-1:0] b);
  typedef struct packed { logic [W-1:0] x; logic [W-1:0] y; } it_t;
  localparam it_t I = '{x: W'(A) + 1, y: A * 2 + 1};
  assign b = a ? I.x : I.y;
endmodule
