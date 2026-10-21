// § oneTickUpperBNormalized425
package p;
  parameter P = 1'B1;
  parameter N = 1'B0;
endpackage
module top(input logic a, output logic y, output logic z);
  import p::*;
  assign y = a & P;
  assign z = a | p::N;
endmodule
