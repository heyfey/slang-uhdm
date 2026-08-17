// q2 — the § queueLocalElemTsInstance40 PRECEDENT: a queue LOCAL of a package
// free function.  Golden stamps the home package here; this cell is the control
// that the fix must NOT move.
package p2;
  typedef struct { int a; } s2_t;
  function int f2();
    s2_t q2[$];
    q2.push_back('{a:1});
    return q2.size();
  endfunction
endpackage
module top2;
  int r2;
  initial r2 = p2::f2();
endmodule
