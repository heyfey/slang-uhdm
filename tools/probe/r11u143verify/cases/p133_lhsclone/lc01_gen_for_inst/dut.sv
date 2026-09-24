// § impPaLhsDisjointClone133
// case lc01: header-import module with a parameter port list, instantiated in a generate for
package gp; parameter int GW = 3; parameter int GD = 2; endpackage
module leaf import gp::*; #(parameter int W = GW, parameter int D = GD) (input logic [W-1:0] a, output logic [W-1:0] o);
  assign o = a + D;
endmodule
module top(input logic [5:0] a, output logic [5:0] o);
  for (genvar g = 0; g < 2; g++) begin : gl
    leaf u(.a(a[g*3 +: 3]), .o(o[g*3 +: 3]));
  end
endmodule
