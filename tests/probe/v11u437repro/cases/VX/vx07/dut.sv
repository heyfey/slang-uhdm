// § foreachCgArrLoopVarRef437
module top(input a);
covergroup cg; coverpoint a; endgroup
function automatic void f(ref cg arr[2]); foreach (arr[i]) arr[i] = new; endfunction
cg cs[2];
initial f(cs);
endmodule
