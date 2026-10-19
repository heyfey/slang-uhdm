// § modImpTdParamTsClone409
package p;
  typedef int unsigned u_t;
  parameter u_t A = 7;
endpackage
module top (output [7:0] o);
  import p::*;
  assign o = A;
endmodule
