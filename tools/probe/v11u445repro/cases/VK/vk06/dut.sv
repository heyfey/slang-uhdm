// § pkgSubLoopVarReadBindsDecl445
package pk;
function automatic int f(); int a[4]; int b[2]; int s; int i; foreach (a[i]) foreach (b[j]) s = s + i + j; return s; endfunction
endpackage
module top; int x = pk::f(); endmodule
