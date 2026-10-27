// § ifaceLoopVarReadBindsDecl445
interface ifc;
logic [3:0] sig; int s; int i;
task automatic t; foreach (sig[i]) s = s + i; endtask
initial t();
endinterface
module top; ifc u(); endmodule
