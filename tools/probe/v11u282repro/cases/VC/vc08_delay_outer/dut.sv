// § genCaSelBoundNestedOwner282
module top #(parameter int P = 3) (input logic [7:0] b, output logic [3:0] z);
  if (1) begin : gi
    assign #1 z = b[P:0] & 4'hF;
  end
endmodule
