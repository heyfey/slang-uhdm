// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[2];
initial begin
  automatic int n = 0;
  foreach (cs[k]) begin cs[k] = new; n++; end
end
endmodule
