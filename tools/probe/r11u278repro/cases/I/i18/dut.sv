// § ifaceElabTypeParamIsDefObj278
typedef struct packed { logic a; logic b; } s_t;
interface ifc #(parameter type T = s_t) ();
  logic [1:0] x;
endinterface
module top; ifc u(); endmodule
