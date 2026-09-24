// § pkgParamTsRefColons131
package pk;
  parameter int N = 2;
  parameter int P [N] = '{1, 2};
endpackage
module top (output logic [31:0] o);
  assign o = pk::P[0];
endmodule
