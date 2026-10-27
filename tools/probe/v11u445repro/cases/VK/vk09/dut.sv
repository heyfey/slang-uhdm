// § pkgSubLoopVarReadBindsDecl445
package pk;
typedef logic [2:0] n_t;
function automatic int f(); int arr[4]; int s; n_t i; foreach (arr[i]) s = s + i; return s; endfunction
endpackage
module top; int x = pk::f(); endmodule
