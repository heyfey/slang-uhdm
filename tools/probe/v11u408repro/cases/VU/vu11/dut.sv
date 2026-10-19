// § classImpTdParamTsClone408
package p;
  typedef real r_t;
  parameter r_t A = 1.5;
endpackage
import p::*;
class c;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
