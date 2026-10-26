// § foreachCgArrLoopVarRef437
package p;
covergroup cg with function sample(int x); coverpoint x; endgroup
endpackage
module top;
p::cg cs[3];
initial foreach (cs[i]) cs[i] = new;
endmodule
