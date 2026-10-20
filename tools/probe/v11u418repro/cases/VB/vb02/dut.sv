// § tdMoveRenamesBitSelect418
package pk; parameter int P[1:0] = '{3, 2}; endpackage
module m (input logic a);
  typedef struct packed { logic [pk::P[1]-1:0] f; } h_s;
  for (genvar i = 0; i < 2; i++) begin : g
    h_s hdr;
    assign hdr = '0;
  end
endmodule
module top; endmodule
