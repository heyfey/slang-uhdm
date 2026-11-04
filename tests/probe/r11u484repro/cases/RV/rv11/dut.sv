// § ownNamedAliasLocalIsRefVar484 (class property of a package alias of a struct)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  class C;
    op2_t acc;
    function int f(); return acc.data; endfunction
  endclass
endpackage
module top;
  u::C c;
endmodule
