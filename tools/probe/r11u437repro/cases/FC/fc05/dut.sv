// § foreachCgArrLoopVarRef437
interface ifc (input clk, input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial foreach (cs[i]) cs[i] = new;
endinterface
module top(input clk, input a); ifc u(clk, a); endmodule
