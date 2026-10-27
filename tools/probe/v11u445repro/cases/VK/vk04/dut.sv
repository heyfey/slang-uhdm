// § pkgSubLoopVarReadBindsDecl445
package pk;
function int f(); int arr[4]; int s; static int i; foreach (arr[i]) s = s + i; return s; endfunction
endpackage
module top; int x; initial x = pk::f(); endmodule
