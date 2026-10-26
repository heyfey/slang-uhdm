// § foreachCgArrLoopVarRef437
module top(input clk, input a);
covergroup cg; coverpoint a; endgroup
cg c[2][3];
initial foreach (c[i,j]) c[i][j] = new;
endmodule
