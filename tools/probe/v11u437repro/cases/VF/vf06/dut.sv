// § foreachCgArrLoopVarRef437
module sub(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial foreach (cs[i]) cs[i] = new;
endmodule
module top(input a); sub u1(a); sub u2(a); endmodule
