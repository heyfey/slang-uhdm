// § classImpTdParamTsClone408
package p;
  typedef bit signed [3:0] sb_t;
  parameter sb_t A = -4'sd2;
endpackage
import p::*;
class c;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
