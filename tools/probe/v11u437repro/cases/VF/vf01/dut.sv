// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2][3];
initial foreach (cs[i, j]) cs[i][j] = new;
endmodule
