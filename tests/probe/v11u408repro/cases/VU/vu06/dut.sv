// § classImpTdParamTsClone408
package p;
  typedef logic [7:0] ft_t;
  parameter ft_t A = 8'h3;
endpackage
import p::*;
class c #(int W = 2);
  int x;
endclass
module top;
  c #(3) h;
  initial h = new;
endmodule
