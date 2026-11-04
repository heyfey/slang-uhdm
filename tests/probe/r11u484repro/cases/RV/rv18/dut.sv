// § ownNamedAliasLocalIsRefVar484 (module function local of a module alias of a package struct)
package p;
  typedef struct { int k; int d; } base_t;
endpackage
module top;
  typedef p::base_t op_t;
  function int f(int n);
    op_t acc;
    acc.k = n;
    return acc.k;
  endfunction
  int x;
  initial x = f(1);
endmodule
