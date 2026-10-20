// § tdMoveRenamesBitSelect418
package pk;
  localparam int A[2] = '{3, 4};
endpackage
module m (input logic a);
  typedef struct packed { logic [pk::A[1]-1:0] cord; } h_s;
  for (genvar i = 0; i < 2; i++) begin : g
    h_s hdr;
    assign hdr = '0;
  end
endmodule
module top; endmodule
