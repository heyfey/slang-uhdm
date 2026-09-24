// § pkgParamTsRefColons131
package pk;
  parameter int H = 7;
  parameter int L = 2;
  parameter logic [H:L] P = '1;
endpackage
module top (output logic [5:0] o);
  import pk::*;
  assign o = P;
endmodule
