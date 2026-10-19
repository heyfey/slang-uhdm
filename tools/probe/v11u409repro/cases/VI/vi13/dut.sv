// § modImpTdParamTsClone409
package p;
  typedef integer g_t;
  typedef bit [3:0] ft_t;
  parameter g_t G = 3;
  parameter ft_t F[2] = '{4'd1, 4'd2};
endpackage
import p::*;
module top (output [3:0] o);
  assign o = G + F[1];
endmodule
