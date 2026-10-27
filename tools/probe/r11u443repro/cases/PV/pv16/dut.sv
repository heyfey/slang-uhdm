// § foreachPackedRefDeclTs443
interface ifc; logic [3:0] sig; int s; initial foreach (sig[i]) s = s + sig[i]; endinterface
module top; ifc u(); endmodule
