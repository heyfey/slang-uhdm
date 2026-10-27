// § foreachPackedRefDeclTs443
interface ifc; logic [3:0] sig; endinterface
module top; ifc u(); int s; initial foreach (u.sig[i]) s = s + i; endmodule
