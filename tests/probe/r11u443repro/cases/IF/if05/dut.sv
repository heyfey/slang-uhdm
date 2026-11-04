// § elabIfaceLoopVarReadBinds443
interface ifc; byte ba[3]; int s; initial foreach (ba[k]) s = s + k; endinterface
module top; ifc u(); endmodule
