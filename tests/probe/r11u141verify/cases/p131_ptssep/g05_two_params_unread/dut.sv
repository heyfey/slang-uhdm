// § pkgParamTsRefColons131
// case g05: two package parameters ranged by package parameters (one a sum), module imports the package
package pk;
  parameter int unsigned NA = 4;
  parameter int unsigned NB = 2;
  parameter logic [NA-1:0] P1 = '1;
  parameter logic [NA+NB-1:0] P2 = '0;
endpackage
module top(output logic o);
  import pk::*;
  assign o = 1'b1;
endmodule
