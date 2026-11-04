// § nestedLoopVarSkipsOuter445v
module top;
int a[4]; int b[2]; int s;
function automatic int f(); int r; foreach (a[i]) foreach (b[i]) r = r + i; return r; endfunction
initial s = f();
endmodule
