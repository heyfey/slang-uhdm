// § pkgSubLoopVarReadBindsDecl445
package pk;
parameter int i = 3;
function automatic int f(); int arr[4]; int s; foreach (arr[i]) s = s + i; return s; endfunction
endpackage
module top; int x = pk::f(); endmodule
