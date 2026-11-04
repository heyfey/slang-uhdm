// § pkgSelIdxRefColons254 (decode: the module parameter as the first index and as the middle index)
package cp;
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top #(parameter int W = 1) (output logic [7:0] o, output logic [7:0] p);
  assign o = cp::R3[W-1][0];
  assign p = cp::R3[0][W-1];
endmodule
