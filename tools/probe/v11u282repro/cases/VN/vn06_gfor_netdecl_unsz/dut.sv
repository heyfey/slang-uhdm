// § genCaSelBoundUnsizedClone282
module top #(parameter int P = 2) (input logic [7:0] b, input logic c, output logic [1:0] z [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    wire [1:0] w = c ? '0 : b[P +: 2];
    assign z[g] = w;
  end
endmodule
