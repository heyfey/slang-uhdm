// § patFlatMemberLeftSpan169
module top #(parameter int W = 8) (input logic a, output logic [W-1:0] b);
  typedef struct packed { logic [W-1:0] x; logic [W-1:0] y; } it_t;
  localparam it_t I = '{x: (W + 1) * 2, y: W - 1 - 2};
  assign b = a ? I.x : I.y;
endmodule
