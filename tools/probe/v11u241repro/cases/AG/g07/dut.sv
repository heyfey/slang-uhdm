// § cloneAggMemberOwn241
package p;
  typedef struct packed { logic [1:0] a; logic [5:0] b; } s_t;
  class c;
    extern function logic [5:0] g(s_t x);
  endclass
  function logic [5:0] c::g(s_t x);
    s_t y;
    y = x;
    y.a = 2'b01;
    return y.b + x.b + {y.a, y.a, y.a};
  endfunction
endpackage
package q;
  import p::*;
  class u; c x; endclass
endpackage
module top;
  import p::*;
  import q::*;
  u w; c z;
endmodule
