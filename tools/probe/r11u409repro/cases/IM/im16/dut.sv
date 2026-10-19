// § modImpTdParamTsClone409
package q;
  typedef bit [3:0] ft_t;
endpackage
package p;
  import q::*;
  parameter ft_t A = 4'd5;
endpackage
import p::*;
module top;
endmodule
