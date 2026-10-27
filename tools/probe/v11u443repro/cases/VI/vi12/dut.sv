// § elabIfaceLoopVarReadBinds443
interface ifc; logic [3:0] sig; int s; task t(); foreach (sig[i]) s = s + i; endtask initial t(); endinterface
module top; ifc u(); endmodule
