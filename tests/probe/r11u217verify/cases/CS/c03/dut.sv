// § classTdPkgEnumMemberShares209 — r11u217 c03: the package enum typedef ALSO used by a package function formal and a module port, and read through two classes' struct members (a derived class inheriting the typedef)
package p;
  typedef enum { A, B, C } e_t;
  function automatic e_t nx(e_t x); return e_t'(x + 1); endfunction
  class base;
    typedef struct { e_t m; } s_t;
    s_t st;
  endclass
  class der extends base;
    function void f(); st.m = nx(st.m); endfunction
  endclass
endpackage
module top (input p::e_t i, output p::e_t o);
  assign o = p::nx(i);
endmodule
