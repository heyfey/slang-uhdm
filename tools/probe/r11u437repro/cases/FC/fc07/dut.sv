// § foreachCgArrLoopVarRef437
module top(input clk, input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
int n[2];
initial begin foreach (n[i]) n[i] = i; foreach (cs[i]) cs[i] = new; end
endmodule
