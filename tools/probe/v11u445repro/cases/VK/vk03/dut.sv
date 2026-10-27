// § pkgSubLoopVarReadBindsDecl445
package pk;
function automatic int f(); int arr[4]; int s; int i; begin foreach (arr[i]) s = s + i; end return s; endfunction
endpackage
module a; int x = pk::f(); endmodule
module top; a u1(); a u2(); endmodule
