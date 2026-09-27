// § incDecMemberSelIsLvalue184: inc/dec member selects on a package variable, an implicit-this class property, a class handle chain and an expression-position increment
package p;
  typedef struct packed { logic [7:0] f; } s_t;
  s_t ps;
endpackage
module top;
  import p::*;
  s_t s;
  int k, x;
  class H; s_t hs; endclass
  class C;
    s_t cs;
    H h;
    function void g(int j);
      cs.f[j]++;
      h.hs.f[j]--;
      p::ps.f[j]++;
    endfunction
  endclass
  initial begin
    p::ps.f[k]++;
    x = s.f[k]++;
    s.f[k + 1]++;
  end
endmodule
