// § nestedLoopVarSkipsOuter445v
package pk;
function automatic int f(); int a[4]; int b[2]; int s; foreach (a[i]) foreach (b[i]) s = s + i; return s; endfunction
endpackage
module top; int x = pk::f(); endmodule
