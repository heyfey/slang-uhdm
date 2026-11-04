// § genProcOpFoldInPlace282
package pk; parameter int NB = 3; parameter int ND = 2; endpackage
module top import pk::*; (input logic clk, output logic [7:0] r [2]);
  for (genvar w = 0; w < 2; w++) begin : g
    always_ff @(posedge clk) r[w] <= NB + ND;
  end
endmodule
