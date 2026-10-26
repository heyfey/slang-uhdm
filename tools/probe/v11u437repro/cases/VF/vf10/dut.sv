// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial begin foreach (cs[i]) begin cs[i] = new; end end
endmodule
