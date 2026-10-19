// § modImpTdParamTsClone409
package p;
  typedef shortint s_t;
  typedef longint l_t;
  parameter s_t A = 7;
  parameter l_t B = 9;
endpackage
import p::*;
module top (output [7:0] o);
  assign o = A + B;
endmodule
