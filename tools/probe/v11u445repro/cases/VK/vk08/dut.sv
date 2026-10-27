// § pkgSubLoopVarReadBindsDecl445
package pk;
function automatic int f(output int i); int arr[4]; int s; i = 0; foreach (arr[i]) s = s + i; return s; endfunction
endpackage
module top; int x, y; initial x = pk::f(y); endmodule
