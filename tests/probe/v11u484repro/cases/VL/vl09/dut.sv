// § ownNamedAliasLocalIsRefVar484 (package alias of an enum typedef and a local of it plus the enum read)
package u;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef e_t e2_t;
  function int f(int n);
    e2_t e;
    e = B;
    return int'(e) + n;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
