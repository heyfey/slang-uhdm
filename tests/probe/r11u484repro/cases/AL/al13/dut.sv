// § aliasTdMembTsInstAtAlias484 (an alias declared in the importer of a home struct, local in the importer's own function: not a clone)
package u;
  typedef struct { int k; int data; } op_t;
endpackage
package a;
  import u::*;
  typedef op_t op2_t;
  function int g(int n);
    op2_t acc;
    acc.k = n;
    return acc.k;
  endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g(1);
endmodule
