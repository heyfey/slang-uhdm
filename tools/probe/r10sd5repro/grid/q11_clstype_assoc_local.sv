// q11 — the ASSOCIATIVE twin of q9 (§ assocLocalArrayVar40's site, the other
// `elemTs->Instance(tsInst)` in TaskFuncEmit).  Same class-homed typedef, same
// out-of-body method local, associative spelling.  Measured BEFORE deciding
// whether the fix applies to that site too.
package p11;
  class c11;
    typedef struct { int a; string b; } t11_t;
    t11_t m11[string];
    extern function int f11();
  endclass
  function int c11::f11();
    t11_t l11[string];
    l11["k"] = '{a:1, b:"x"};
    return l11.size() + m11.size();
  endfunction
endpackage
module top11;
  p11::c11 h11;
  initial h11 = new();
endmodule
