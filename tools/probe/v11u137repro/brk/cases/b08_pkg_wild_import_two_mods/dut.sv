// § packedArrTdElemRefName137
package p;
  typedef struct packed { logic a; } s_t;
  typedef s_t [3:0] sa_t;
endpackage
module sub(output logic o);
  import p::*;
  sa_t w;
  assign o = w[0].a;
endmodule
module top(output logic o);
  import p::*;
  sa_t v;
  sub u(.o());
  assign o = v[2].a;
endmodule
