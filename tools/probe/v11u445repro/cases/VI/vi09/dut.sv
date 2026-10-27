// § ifaceLoopVarReadBindsDecl445
interface inner; logic [3:0] sig; int s; int i;
initial foreach (sig[i]) s = s + i;
endinterface
interface outer; inner n(); endinterface
module top; outer o(); endmodule
