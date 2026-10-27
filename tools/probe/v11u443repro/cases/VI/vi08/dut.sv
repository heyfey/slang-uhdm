// § elabIfaceLoopVarReadBinds443
interface ifc; string str; int s; initial foreach (str[i]) s = s + i; endinterface
module top; ifc u(); endmodule
