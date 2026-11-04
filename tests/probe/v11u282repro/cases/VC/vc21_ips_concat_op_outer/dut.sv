// § genCaSelBoundNestedOwner282
module top #(parameter int P = 2) (input logic [7:0] b, output logic [3:0] z [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign z[g] = {b[P +: 2], 2'd0} | 4'd0;
  end
endmodule
