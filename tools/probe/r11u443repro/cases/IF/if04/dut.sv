// § elabIfaceLoopVarReadBinds443
interface ifc; string str; int s; initial foreach (str[k]) s = s + k; endinterface
module top; ifc u(); endmodule
