// § ownNamedAliasLocalIsRefVar484 (package function local of a plain struct typedef: the control)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
