// § pkgSubLoopVarReadBindsDecl445
package pk;
function automatic int f(); int m[2][3]; int s; int j; foreach (m[i, j]) s = s + i + j; return s; endfunction
endpackage
module top; int x = pk::f(); endmodule
