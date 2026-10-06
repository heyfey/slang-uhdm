// § pkgSelIdxRefColons254 (continuous assignments: one, two and three select levels, the parameter in the first, middle and last position)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top #(parameter int W = 1) (output logic [7:0] o, output logic [7:0] p, output logic [3:0] q, output logic [3:0] r);
  assign o = cp::R3[W-1][0];
  assign p = cp::R3[0][W-1];
  assign q = cp::R3[1][0][W+2:0];
  assign r = cp::RC[W][W+2:W-1];
endmodule
