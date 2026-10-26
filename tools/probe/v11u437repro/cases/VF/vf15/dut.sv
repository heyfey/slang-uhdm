// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
int n;
initial foreach (cs[i]) n += i;
endmodule
