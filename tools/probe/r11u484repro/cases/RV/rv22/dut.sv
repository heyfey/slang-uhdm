// § ownNamedAliasLocalIsRefVar484 (package function local of an alias in a generate-free module task, plus an out-of-body class method of the package)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  class C;
    extern function int m(int n);
  endclass
  function int C::m(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
module top;
  u::C c;
endmodule
