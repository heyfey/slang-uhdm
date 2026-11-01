// § pkgNestedAnonAggMemberInst461
package p;
  typedef struct packed { union packed { logic [3:0] a; bit [3:0] b; } u; bit [3:0] y; } s_t;
endpackage
package ap;
  import p::*;
  function automatic logic [3:0] f(s_t s);
    return s.u.a;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  import ap::*;
  assign o = f(i);
endmodule
