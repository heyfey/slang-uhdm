// § classImpTdParamTsClone408
package p;
  typedef logic [7:0] ft_t;
  typedef ft_t gt_t;
  typedef gt_t ht_t;
  parameter ht_t A = 8'h3;
endpackage
import p::*;
class c;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
