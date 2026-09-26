// § patFlatMemberLeftSpan169
`define ADD(a, b) (a + b)
module top (input logic a, output logic [7:0] b);
  typedef struct packed { logic [7:0] x; logic [7:0] y; } it_t;
  localparam it_t I = '{x: `ADD(3, 4), y: 2 * 3};
  assign b = a ? I.x : I.y;
endmodule
