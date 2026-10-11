// § genCaSelBoundUnsizedClone282
module top #(parameter int unsigned S = 4) (input logic [1:0] c, input logic [7:0] x, output logic [7:0] y6 [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign y6[g] = c[g] ? '0 : x[S:0];
  end
endmodule
