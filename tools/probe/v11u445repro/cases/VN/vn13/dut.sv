// § foreachLoopVarShadowDeclTs445
package pk;
function automatic int f(); int a[4]; int b[2]; int s; begin int i; foreach (a[i]) foreach (b[i]) s = s + i; end return s; endfunction
endpackage
module top; int x = pk::f(); endmodule
