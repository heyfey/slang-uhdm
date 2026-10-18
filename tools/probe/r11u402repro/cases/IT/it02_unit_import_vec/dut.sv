// § unitImpTdParamTsClone402
package p;
  typedef logic [7:0] w_t;
  parameter w_t B = 8'h5;
  parameter int C = 2;
endpackage
import p::*;
module top;
  logic [7:0] x = B;
endmodule
