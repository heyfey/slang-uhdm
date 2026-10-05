// § pkgAliasOfKwBind250
// alias-of-keyword typedefs as a port type, a struct member, a package function return and formal, and qualified
package p;
  typedef byte b_t;
  typedef b_t bb_t;
  typedef longint unsigned u_t;
  typedef u_t uu_t;
  typedef struct packed { bb_t a; uu_t b; } s_t;
  function automatic bb_t f(uu_t x);
    return bb_t'(x);
  endfunction
endpackage
module leaf(input p::bb_t i, output p::uu_t o);
  assign o = p::uu_t'(i);
endmodule
module top(input byte i, output longint unsigned o, output byte r);
  import p::*;
  s_t s;
  bb_t v;
  p::uu_t w;
  assign s = '{a: i, b: 64'd1};
  assign v = f(s.b);
  assign w = s.b;
  assign r = v;
  leaf l(.i(i), .o(o));
endmodule
