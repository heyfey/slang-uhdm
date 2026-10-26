// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
if (1) begin : g
  cg cs[2];
  initial foreach (cs[i]) cs[i] = new;
end
endmodule
