// § genCaSelBoundNestedOwner282
module top #(parameter int P = 2) (input logic [7:0] b, output logic [1:0] z);
  if (1) begin : gi
    assign t = b[P +: 2] | 2'd0;
  end
  wire [1:0] t;
  assign z = t;
endmodule
