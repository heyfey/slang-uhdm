// § loopVarReadBindsModuleDecl439
module top(input clk, input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
int i;
initial foreach (cs[i]) cs[i] = new;
endmodule
