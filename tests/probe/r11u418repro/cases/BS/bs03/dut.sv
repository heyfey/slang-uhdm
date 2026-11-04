// § tdMoveRenamesBitSelect418
module m #(parameter D = 2, parameter int P[D:0] = '{5, 4, 0}, parameter L = 3) (input logic a);
  typedef struct packed { logic [L-1:0] len; logic [P[D]-1:0] cord; } h_s;
  if (L == 3) begin : g
    h_s hdr;
    assign hdr = '0;
  end
endmodule
module top; endmodule
