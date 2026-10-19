// § classImpTdParamTsClone408
package p;
  typedef logic [7:0] ft_t;
  parameter ft_t A = 8'h3;
endpackage
import p::*;
class c;
  int x = A;
endclass
module top;
  c h;
  initial h = new;
endmodule
