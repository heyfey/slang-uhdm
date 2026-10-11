// § genCaCastFoldOrphanName282
module top #(parameter int P = 3) (output logic [7:0] z [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign z[g] = signed'(P);
  end
endmodule
