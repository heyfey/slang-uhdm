// § modImpTdParamTsClone409
package p;
  typedef bit [3:0] ft_t;
endpackage
package q;
  parameter p::ft_t B = 4'd2;
endpackage
import q::*;
module top (output [3:0] o);
  assign o = B;
endmodule
