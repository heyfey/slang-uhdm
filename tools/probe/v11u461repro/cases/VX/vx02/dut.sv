// § pkgNestedAnonAggMemberInst461
package p;
  typedef struct packed { union packed { logic [3:0] a; logic [3:0] b; } u; struct packed { logic [1:0] c; logic [1:0] d; } t; } s_t;
endpackage
module top(input logic [7:0] i, output logic [3:0] o, output logic [1:0] z);
  import p::*;
  s_t v;
  always_comb begin
    v = i;
    o = v.u.b;
    z = v.t.d;
  end
endmodule
