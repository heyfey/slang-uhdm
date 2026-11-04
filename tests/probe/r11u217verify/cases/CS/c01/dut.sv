// § classTdPkgEnumMemberShares209 — r11u217 c01: TWO classes each with a class-scope struct typedef whose member is the same package enum typedef, and a module reading the enum through a struct of its own
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  class k1;
    typedef struct { e_t m; int i; } s1_t;
    s1_t q;
    function void f(); q.m = B; endfunction
  endclass
  class k2;
    typedef struct packed { e_t m; logic [3:0] n; } s2_t;
    s2_t r;
    function e_t g(); return r.m; endfunction
  endclass
endpackage
module top (output logic [1:0] o);
  typedef struct packed { p::e_t m; } ms_t;
  ms_t v;
  assign v.m = p::C;
  assign o = v.m;
endmodule
