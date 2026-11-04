// § ifaceLoopVarReadBindsDecl445
interface ifc;
logic [3:0] sig; int s;
always_comb begin int i; s = 0; foreach (sig[i]) s = s + i; end
endinterface
module top; ifc u(); endmodule
