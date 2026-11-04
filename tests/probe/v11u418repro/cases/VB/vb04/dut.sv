// § tdMoveRenamesBitSelect418
module m #(parameter logic [7:0] V = 8'h35) (input logic a);
  typedef struct packed { logic [V[3:0]:0] c; logic [V[2]:0] d; } h_s;
  for (genvar i = 0; i < 2; i++) begin : g
    h_s hdr;
    assign hdr = '0;
  end
endmodule
module top; endmodule
