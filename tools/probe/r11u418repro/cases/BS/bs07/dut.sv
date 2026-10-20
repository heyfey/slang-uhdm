// § tdMoveRenamesBitSelect418
module m #(parameter D = 2, parameter int P[D:0] = '{5, 4, 0}, parameter L = 3) (input logic a);
  typedef union packed { logic [9:0] len; logic [P[D]+4:0] cord; } h_s;
  for (genvar i = 0; i < 2; i++) begin : g
    h_s hdr;
    assign hdr = '0;
  end
endmodule
module top; endmodule
