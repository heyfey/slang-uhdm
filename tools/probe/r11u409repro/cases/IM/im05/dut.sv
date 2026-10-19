// § modImpTdParamTsClone409
package p;
  parameter W = 6;
  typedef bit [W-1:0] ft_t;
  parameter ft_t A = 1;
  parameter ft_t B = A << 2;
endpackage
import p::*;
module top;
endmodule
