// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
task automatic t(); foreach (cs[i]) cs[i] = new; endtask
initial t();
endmodule
