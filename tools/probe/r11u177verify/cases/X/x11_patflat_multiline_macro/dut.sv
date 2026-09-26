// § patFlatMemberLeftSpan169 § ppOutputLine166 § ppOutputCol166 § tagPatSortSrcOrder177v
`define ADD2(x, y) \
  ((x) + \
   (y))
module top #(parameter int W = 8) (input logic a, output logic [W-1:0] b);
  typedef struct packed {
    logic [W-1:0] x;
    logic [W-1:0] y;
  } it_t;
  localparam it_t I = '{x: `ADD2(W, 1) * 2, y: W - `ADD2(1, 1)};
  assign b = a ? I.x : I.y;
endmodule
