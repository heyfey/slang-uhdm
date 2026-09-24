// § pkgParamTsRefColons131
package a;
  parameter int W = 4;
endpackage
package b;
  parameter logic [a::W-1:0] P = '1;
endpackage
module top (output logic [3:0] o);
  assign o = b::P;
endmodule
