// § ownNamedAliasLocalIsRefVar484 (package function local of a packed struct alias, fixed array)
package u;
  typedef struct packed { logic [3:0] k; logic [7:0] data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc [2];
    acc[0].k = n;
    return acc[1].data;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule
