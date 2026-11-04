// § ifaceLoopVarReadBindsDecl445
module top;
logic [3:0] sig; int s; event i;
initial foreach (sig[i]) s = s + i;
endmodule
