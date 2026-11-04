// § cloneViaProviderTopClone476
package u;
  typedef struct { int a; int b; } s_t;
  function automatic int f(ref s_t s, output int o);
    s.a = s.b;
    o = s.a;
    return s.a + 1;
  endfunction
endpackage
package a;
  import u::*;
  class AC; function int g(); s_t q; int o; return f(q, o); endfunction endclass
endpackage
package t;
  import a::*;
  class TC; AC h; endclass
endpackage
module top; import t::*; TC o; endmodule
