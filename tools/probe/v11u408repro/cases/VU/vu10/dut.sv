// § classImpTdParamTsClone408
package p;
  typedef string s_t;
  parameter s_t A = "ab";
endpackage
import p::*;
class c;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
