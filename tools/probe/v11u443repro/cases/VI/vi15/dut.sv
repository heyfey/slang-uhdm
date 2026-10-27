// § elabIfaceLoopVarReadBinds443
typedef struct packed { logic [3:0] f; } s_t;
interface ifc;
s_t a [3]; int s;
initial foreach (a[i]) s = s + i;
endinterface
module top; ifc u(); endmodule
