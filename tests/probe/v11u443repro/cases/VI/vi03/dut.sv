// § elabIfaceLoopVarReadBinds443
interface ifc; logic [3:0] sig; int s; initial foreach (sig[i]) s = s + i; endinterface
module top; for (genvar g = 0; g < 2; g++) begin : gb ifc u(); end endmodule
