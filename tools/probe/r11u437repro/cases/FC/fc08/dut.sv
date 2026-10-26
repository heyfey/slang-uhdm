// § foreachCgArrLoopVarRef437
module top(input clk, input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
task automatic mk(); foreach (cs[i]) cs[i] = new; endtask
initial mk();
endmodule
