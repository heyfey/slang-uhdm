// § ownNamedAliasLocalIsRefVar484 (package function returning and holding a home enum alias)
package u;
  typedef enum logic [1:0] { A, B } e_t;
  typedef e_t e2_t;
  function e2_t f(int n);
    e2_t v;
    v = B;
    return v;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
