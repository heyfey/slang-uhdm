// § foreachCgArrLoopVarRef437
module top(input clk, input [3:0] a);
covergroup cg(int lim) @(posedge clk); coverpoint a { bins lo = {[0:lim]}; } endgroup
cg c2[2];
initial foreach (c2[k]) c2[k] = new(k);
endmodule
