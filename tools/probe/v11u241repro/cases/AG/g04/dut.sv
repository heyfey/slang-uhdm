// § cloneAggLocalOwnCopy241
package p;
  typedef struct { int a; } s_t;
  typedef enum { X, Y } e_t;
endpackage
package r;
  import p::*;
  typedef struct { int b; } t_t;
  function automatic int f(p::s_t a, t_t t, e_t e);
    p::s_t loc;
    loc = a;
    return loc.a + t.b + int'(e);
  endfunction
endpackage
package q;
  import r::*;
endpackage
module top;
  import r::*;
  int x;
endmodule
