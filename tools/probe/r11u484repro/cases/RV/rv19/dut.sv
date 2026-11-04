// § ownNamedAliasLocalIsRefVar484 (interface function local of an interface alias of a struct)
interface ifc;
  typedef struct packed { logic [3:0] k; logic [3:0] d; } op_t;
  typedef op_t op2_t;
  function automatic logic [3:0] f(logic [3:0] n);
    op2_t acc;
    acc.k = n;
    return acc.d;
  endfunction
endinterface
module top;
  ifc i();
  logic [3:0] x;
  initial x = i.f(4'd1);
endmodule
