// § foreachCgArrLoopVarRef437
module top(input clk, input a);
covergroup cg; coverpoint a; endgroup
cg d[];
initial begin d = new[2]; foreach (d[i]) d[i] = new; end
endmodule
