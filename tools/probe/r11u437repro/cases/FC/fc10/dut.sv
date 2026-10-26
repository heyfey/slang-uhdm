// § foreachCgArrLoopVarRef437
module top(input clk, input a);
covergroup cg; coverpoint a; endgroup
cg q[$];
initial begin q.push_back(null); foreach (q[i]) q[i] = new; end
endmodule
