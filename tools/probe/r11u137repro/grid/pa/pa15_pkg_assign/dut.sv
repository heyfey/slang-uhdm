// § packedArrTdElemRefName137
package p;
  typedef struct packed {logic a; logic [2:0] b;} s_t;
  typedef s_t [1:0] sa_t;
endpackage
module top(output logic [7:0] o);
  import p::*;
  sa_t v;
  assign v = '0;
  assign o = v;
endmodule
