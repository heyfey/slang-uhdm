// § modImpTdParamTsClone409
package p;
  typedef bit [3:0] ft_t;
  class c #(parameter ft_t W = 4'd1);
    ft_t x = W;
  endclass
endpackage
module top;
  import p::*;
  c #(4'd2) h = new;
endmodule
