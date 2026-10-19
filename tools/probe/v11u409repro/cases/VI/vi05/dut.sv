// § modImpTdParamTsClone409
package p;
  typedef bit signed [7:0] s_t;
  parameter s_t A = -8'sd3;
endpackage
import p::*;
module top (output [7:0] o);
  assign o = A;
endmodule
