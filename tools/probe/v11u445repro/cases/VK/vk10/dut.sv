// § pkgSubLoopVarReadBindsDecl445
package pk;
function automatic int f(); int arr[4]; int s; int i; foreach (arr[i]) s = s + i; return s; endfunction
endpackage
module top; endmodule
