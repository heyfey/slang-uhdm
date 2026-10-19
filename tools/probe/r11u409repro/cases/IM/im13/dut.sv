// § modImpTdParamTsClone409
package p;
  typedef bit [3:0] ft_t;
endpackage
import p::*;
class c;
  parameter ft_t A = 4'd5;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
