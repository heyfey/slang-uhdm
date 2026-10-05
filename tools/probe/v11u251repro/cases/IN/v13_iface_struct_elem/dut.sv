// § ifaceDynAliasNetType251 (a packed-struct element dynamic typedef in an interface: no four-state vector element)
typedef struct packed { logic a; logic b; } s_t;
typedef s_t d_t [];
interface ifc;
  d_t d;
endinterface
module top; ifc i(); endmodule
