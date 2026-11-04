// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
cg cs[3];
function void mkall(); foreach (cs[i]) cs[i] = new; endfunction
initial mkall();
endmodule
