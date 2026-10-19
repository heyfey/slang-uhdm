// § modImpTdParamTsClone409
package p;
  typedef bit [3:0] ft_t;
  parameter ft_t A = 4'd5;
endpackage
package q;
  import p::*;
  parameter ft_t B = A + 4'd1;
endpackage
import q::*;
module top (output [3:0] o);
  assign o = B;
endmodule
