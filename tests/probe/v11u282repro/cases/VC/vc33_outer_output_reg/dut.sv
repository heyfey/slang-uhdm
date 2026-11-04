// § genCaSelBoundNestedOwner282
module top(b, z);
  parameter int P = 2;
  input [7:0] b; output [1:0] z;
  if (1) begin : gi
    assign z = b[P +: 2] | 2'd0;
  end
endmodule
