// § elabIfaceLoopVarReadBinds443
interface ifc; byte b[4]; int s; initial foreach (b[i]) s = s + i; endinterface
module top; ifc u(); endmodule
