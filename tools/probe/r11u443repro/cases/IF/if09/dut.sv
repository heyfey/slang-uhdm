// § elabIfaceLoopVarReadBinds443
interface ifc; int aa[string]; int s; initial foreach (aa[k]) s = s + aa[k]; endinterface
module top; ifc u(); endmodule
