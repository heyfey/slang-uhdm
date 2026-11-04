// § classImpTdParamTsClone408
package p;
  typedef bit [3:0] ft_t;
  parameter ft_t A = 4'd5;
endpackage
module top;
  import p::*;
  class c;
    int x;
  endclass
  c h;
  initial h = new;
endmodule
