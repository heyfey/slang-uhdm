// § genCaCastFoldOrphanName282
package pk; parameter int P = 3; endpackage
module top import pk::*; (output logic [7:0] z [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign z[g] = 8'(P);
  end
endmodule
