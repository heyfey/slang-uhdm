// § ownNamedAliasLocalIsRefVar484 (package alias local in a package class method (control) and a free function)
package u;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  class C;
    function int m(int n);
      op2_t a;
      a.k = n;
      return a.k;
    endfunction
  endclass
  function int f(int n);
    op2_t b;
    b.d = n;
    return b.d;
  endfunction
endpackage
module top;
  int x;
  initial begin u::C c; c = new; x = c.m(1) + u::f(2); end
endmodule
