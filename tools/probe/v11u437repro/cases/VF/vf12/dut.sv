// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
typedef cg cga_t[2];
cga_t cs;
initial foreach (cs[i]) cs[i] = new;
endmodule
