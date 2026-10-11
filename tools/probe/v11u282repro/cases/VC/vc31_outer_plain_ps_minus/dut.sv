// § genCaSelBoundNestedOwner282
module top #(parameter int P = 5) (input logic [7:0] b, output logic [1:0] z);
  logic [1:0] t;
  assign z = t;
  for (genvar g = 0; g < 1; g++) begin : gb
    assign t = b[P -: 2] + 2'd1;
  end
endmodule
