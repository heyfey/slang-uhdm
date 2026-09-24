// § pkgParamTsRefColons131
// case g04: a package parameter ranged by another package parameter, never read by a module
package pk;
  parameter int unsigned NA = 4;
  parameter logic [NA-1:0] ON = '0;
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
