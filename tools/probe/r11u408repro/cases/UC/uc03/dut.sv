// § classImpTdParamTsClone408
package p;
  typedef logic [7:0] ft_t;
  parameter ft_t A = 8'h3;
  parameter int B = 2;
endpackage
import p::*;
class c;
  int x;
endclass
class d extends c;
  int y;
endclass
module top;
  d h;
  initial h = new;
endmodule
