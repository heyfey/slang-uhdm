// § modAliasTdAtBaseClone484 (interface alias of an interface struct, used by an interface variable)
interface ifc;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  op2_t v;
endinterface
module top(input logic [7:0] i, output logic [3:0] o);
  ifc u();
  assign u.v = i;
  assign o = u.v.a;
endmodule
