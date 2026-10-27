// § pkgSubLoopVarReadBindsDecl445
function automatic int f(); int arr[4]; int s; int i; foreach (arr[i]) s = s + i; return s; endfunction
module top; int x = f(); endmodule
