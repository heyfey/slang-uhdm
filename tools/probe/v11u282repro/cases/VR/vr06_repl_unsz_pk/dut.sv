// § genCaReplCountUnsizedClone282
package pk; parameter int W = 2; endpackage
module top import pk::*; (input logic [7:0] e, output logic [7:0] q [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign q[g][3:0] = {W{e[1:0]}} & '1;
  end
endmodule
