// § packedArrTdElemRefName137
package p;
  typedef struct packed {logic a; logic [2:0] b;} s_t;
  typedef s_t [1:0] sa_t;
endpackage
module top();
  import p::*;
  sa_t v;
endmodule
