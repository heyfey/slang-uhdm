// § genCaCastFoldOrphanName282
module top (output logic [3:0] z [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign z[g] = 4'(5);
  end
endmodule
