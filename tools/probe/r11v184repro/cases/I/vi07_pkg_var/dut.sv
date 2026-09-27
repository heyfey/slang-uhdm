// § incDecMemberSelIsLvalue184: a member-select increment on a package variable, qualified and imported
package p;
  typedef struct packed { logic [7:0] f; } s_t;
  s_t ps;
endpackage
module top;
  import p::*;
  int k;
  initial begin
    p::ps.f[k]++;
    ps.f[k + 1]--;
  end
endmodule
