// § aliasTdMembTsInstAtAlias484 (package function local of a home alias of a struct, the package imported by top)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
module top;
  import u::*;
  int x;
  initial x = f(1);
endmodule
