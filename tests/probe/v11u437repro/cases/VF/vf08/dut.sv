// § foreachCgArrLoopVarRef437
module top(input a, input clk);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial foreach (cs[i]) cs[i] = new;
always @(posedge clk) foreach (cs[i]) cs[i].sample();
endmodule
