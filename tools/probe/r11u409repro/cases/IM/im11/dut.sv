// § modImpTdParamTsClone409
package p;
  typedef bit [3:0] ft_t;
  typedef ft_t gt_t;
  parameter gt_t A = 4'd5;
endpackage
import p::*;
module top;
  logic [3:0] x;
  assign x = A;
endmodule
