// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2][2];
initial foreach (cs[, j]) cs[0][j] = new;
endmodule
