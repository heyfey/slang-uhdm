// § foreachPackedRefDeclTs443
interface ifc; logic [7:0] v; int s; initial foreach (v[i]) s = s + v[i]; endinterface
module top; ifc u(); endmodule
