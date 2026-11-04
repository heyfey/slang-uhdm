// § ownNamedAliasLocalIsRefVar484 (class method local of a package alias)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  class C;
    function int f(int n);
      op2_t acc;
      acc.k = n;
      return acc.data;
    endfunction
  endclass
endpackage
module top;
  u::C c;
endmodule
