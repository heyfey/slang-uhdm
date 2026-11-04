// § genCaCastFoldOrphanName282
module top #(parameter int W = 4, parameter int P = 3) (output logic [3:0] z [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    wire [3:0] w = W'(P);
    assign z[g] = w;
  end
endmodule
