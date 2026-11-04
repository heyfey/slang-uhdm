// § cloneAliasCopyBareName484 (enum alias local in an import clone)
package u;
  typedef enum logic [1:0] { A, B } e_t;
  typedef e_t e2_t;
  function int f(int n);
    e2_t v;
    v = B;
    return n + int'(v);
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
