// § tdMoveRenamesBitSelect418
module m #(parameter int P[2:0] = '{5, 4, 1}) (input logic a);
  typedef union packed { logic [P[0]:0] x; logic [P[0]:0] y; } h_u;
  for (genvar i = 0; i < 2; i++) begin : g
    h_u hdr;
    assign hdr = '0;
  end
endmodule
module top; endmodule
