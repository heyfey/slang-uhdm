// § unitImpTdParamTsClone402
package p;
  typedef int i_t;
  parameter i_t Q = 7;
  localparam i_t L = Q + 1;
endpackage
import p::*;
module top;
  int x = Q;
endmodule
