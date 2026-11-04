// § genCaSelBoundNestedOwner282
module top #(parameter int P = 2) (input logic [7:0] b, output logic [1:0] z [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    wire [1:0] w = b[P +: 2] | 2'd0;
    assign z[g] = w;
  end
endmodule
module wrap(input logic [7:0] b, output logic [1:0] z [2]); top u (.b(b), .z(z)); endmodule
