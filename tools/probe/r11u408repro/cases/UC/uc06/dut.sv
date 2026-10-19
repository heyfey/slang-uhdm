// § classImpTdParamTsClone408
package p;
  typedef bit [3:0] ft_t;
  parameter ft_t A = 4'd5;
endpackage
package q;
  import p::*;
  class c;
    int x;
  endclass
endpackage
module top;
  q::c h;
  initial h = new;
endmodule
