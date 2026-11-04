// § genCaSelBoundUnsizedClone282
module m #(parameter int unsigned S = 4) (input logic [1:0] c, input logic [7:0] x, output logic [7:0] y6 [2], output logic [7:0] zz);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign y6[g] = c[g] ? x[S:0] : '0;
  end
endmodule
module top(input logic [1:0] c, input logic [7:0] x, output logic [7:0] y6 [2], output logic [7:0] zz); m u(.c(c), .x(x), .y6(y6), .zz(zz)); endmodule
