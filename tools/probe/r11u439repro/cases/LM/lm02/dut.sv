// § loopVarReadBindsModuleDecl439
module top;
integer i;
logic [7:0] mem[4];
always_comb foreach (mem[i]) mem[i] = 8'(i);
endmodule
