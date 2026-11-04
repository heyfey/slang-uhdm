// § ownNamedAliasLocalIsRefVar484 (package function local of an alias of an enum)
package u;
  typedef enum logic [1:0] { A, B } e_t;
  typedef e_t e2_t;
  function int f(int n);
    e2_t v;
    v = A;
    return n;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
