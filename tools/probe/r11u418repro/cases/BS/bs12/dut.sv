// § tdMoveRenamesBitSelect418
module m #(parameter D = 2, parameter int P[D:0] = '{5, 4, 0}, parameter L = 3) (input logic a);
  typedef struct packed { logic [P[D]-1:0] cord; } c_s;
  typedef struct packed { c_s c; logic [P[0]-1:0] len; } h_s;
  for (genvar i = 0; i < 2; i++) begin : g
    h_s hdr;
    assign hdr = '0;
  end
endmodule
module top; endmodule
