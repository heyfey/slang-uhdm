// § genCaSelBoundNestedOwner282
module top (input logic [7:0] b, output logic [3:0] z);
  localparam int L = 3;
  for (genvar g = 0; g < 1; g++) begin : gb
    assign z = b[L:0] ~^ 4'd0;
  end
endmodule
