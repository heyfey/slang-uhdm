// § elabIfaceLoopVarReadBinds443
typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
interface ifc; s_t st [2]; int s; initial foreach (st[i]) s = s + i; endinterface
module top; ifc u(); endmodule
