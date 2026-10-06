// § pkgSelIdxRefColons254 (decode: three select levels on a package parameter, the module parameter in the last bound)
package cp;
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top #(parameter int W = 4) (output logic [3:0] o);
  assign o = cp::R3[1][0][W-1:0];
endmodule
