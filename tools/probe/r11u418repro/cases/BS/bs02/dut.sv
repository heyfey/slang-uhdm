// § tdMoveRenamesBitSelect418
`define decl_s(cw, lw, nm) \
typedef struct packed {   \
  logic [lw-1:0] len;     \
  logic [cw-1:0] cord;    \
} nm
module m #(parameter D = 2, parameter int P[D:0] = '{5, 4, 0}, parameter L = 3) (input logic a);
  `decl_s(P[D], L, h_s);
  for (genvar i = 0; i < 2; i++) begin : g
    h_s hdr;
    assign hdr = '0;
  end
endmodule
module top; endmodule
