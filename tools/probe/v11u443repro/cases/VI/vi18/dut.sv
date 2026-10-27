// § elabIfaceLoopVarReadBinds443
typedef struct { int f; } s_t;
interface ifc;
s_t a [3]; int s;
initial foreach (a[i]) s = s + i;
endinterface
module top; ifc u(); endmodule
