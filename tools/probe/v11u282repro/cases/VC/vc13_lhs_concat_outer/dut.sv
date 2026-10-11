// § genCaSelBoundNestedOwner282
module top #(parameter int P = 2) (input logic [7:0] b, output logic [1:0] z, output logic [1:0] y);
  if (1) begin : gi
    assign {z, y} = {b[P +: 2] | 2'd0, 2'd1};
  end
endmodule
