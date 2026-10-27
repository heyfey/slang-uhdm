// § aggCopyClassMemberHomeInst446
package p;
  class C;
  endclass
  typedef struct { C m; string n; } s_t;
  function automatic s_t mk(string n);
    s_t r;
    r.n = n;
    return r;
  endfunction
endpackage
package q;
  import p::*;
  function automatic string g(s_t a);
    s_t b;
    b = a;
    return b.n;
  endfunction
endpackage
module top;
  import p::*;
  import q::*;
  s_t v;
  initial $display(g(mk("x")));
endmodule
