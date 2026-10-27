// § pkgSubLoopVarReadBindsDecl445
package pk;
function automatic int f(int i); int arr[4]; int s; foreach (arr[i]) s = s + i; return s; endfunction
endpackage
module top; int x = pk::f(1); endmodule
