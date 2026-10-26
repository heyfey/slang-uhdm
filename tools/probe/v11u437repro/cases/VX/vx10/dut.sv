// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial begin : blk
  foreach (cs[i]) cs[i] = new;
end
endmodule
