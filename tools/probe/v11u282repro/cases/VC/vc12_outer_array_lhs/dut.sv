// § genCaSelBoundNestedOwner282
module top #(parameter int P = 2) (input logic [7:0] b, output logic [1:0] z);
  logic [1:0] arr [2];
  assign z = arr[0] ^ arr[1];
  for (genvar g = 0; g < 2; g++) begin : gb
    assign arr[g] = b[P +: 2] | 2'd0;
  end
endmodule
