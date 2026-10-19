// § classImpTdParamTsClone408
package p;
  typedef bit [3:0] b_t;
  typedef b_t c_t;
  parameter c_t A = 4'd5;
endpackage
import p::*;
class c;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
