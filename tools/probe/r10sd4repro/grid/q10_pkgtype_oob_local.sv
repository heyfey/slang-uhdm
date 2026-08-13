// q10 — the CONTROL for q9: the identical program with the typedef moved OUT of
// the class into the PACKAGE.  If golden keys on the TYPE'S HOME SCOPE, this
// cell keeps the package stamp while q9 loses it.
package p10;
  typedef struct { int a; string b; } t10_t;
  class c10;
    t10_t m10[$];
    extern function int f10();
  endclass
  function int c10::f10();
    t10_t l10[$];
    l10.push_back('{a:1, b:"x"});
    return l10.size() + m10.size();
  endfunction
endpackage
module top10;
  p10::c10 h10;
  initial h10 = new();
endmodule
