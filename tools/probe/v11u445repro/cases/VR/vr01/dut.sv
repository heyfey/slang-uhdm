// § loopVarParamReadUnbound445
module top;
parameter int item = 2;
int q[$]; int s;
function automatic int f(); return q.sum() with (item + 1); endfunction
initial s = f();
endmodule
