// § aliasTdTargetTopView484 (package alias of a packed struct as a function return and a module port)
package u;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  function automatic op2_t f(logic [7:0] n);
    return n;
  endfunction
endpackage
module top(input logic [7:0] i, output u::op2_t o);
  assign o = u::f(i);
endmodule
