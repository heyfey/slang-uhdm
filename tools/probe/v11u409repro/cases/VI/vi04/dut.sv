// § modImpTdParamTsClone409
package p;
  typedef bit [3:0] a_t;
  typedef a_t b_t;
  parameter b_t A = 4'd9;
endpackage
import p::*;
module top (output [3:0] o);
  assign o = A;
endmodule
