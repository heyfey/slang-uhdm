// § patFlatMemberLeftSpan169
module leaf #(parameter int W = 8) (input logic a, output logic [W-1:0] b);
  typedef struct packed { logic [W-1:0] x; logic [W-1:0] y; } it_t;
  localparam it_t I = '{x: W + 1, y: W * 2};
  assign b = a ? I.x : I.y;
endmodule
module top (input logic a, output logic [15:0] b);
  leaf #(.W(16)) u (.a(a), .b(b));
endmodule
