// § genCaSelBoundNestedOwner282
module top #(parameter int P = 2) (input logic [7:0] b, input logic [1:0] k, output logic [1:0] z [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign z[g] = (k == 2'd0) ? b[P +: 2] : b[P-1 -: 2];
  end
endmodule
