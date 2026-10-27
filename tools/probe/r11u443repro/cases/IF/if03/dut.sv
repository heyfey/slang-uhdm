// § elabIfaceLoopVarReadBinds443
interface ifc; int q[$]; int s; initial foreach (q[k]) s = s + k; endinterface
module top; ifc u(); endmodule
