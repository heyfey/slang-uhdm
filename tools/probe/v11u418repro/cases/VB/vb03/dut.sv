// § tdMoveRenamesBitSelect418
module m #(parameter int P[2:0] = '{5, 4, 1}, parameter D = 1) (input logic a);
  typedef struct packed { logic [P[D]-1:0] c; } in_s;
  typedef struct packed { in_s i; logic [P[0]:0] d; } h_s;
  h_s hdr;
  assign hdr = '0;
endmodule
module top; m u (.a(1'b0)); endmodule
