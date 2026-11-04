// § foreachLoopVarShadowDeclTs445
package pk;
function automatic int f(); int arr[4]; int s; begin : nb int i; foreach (arr[i]) s = s + arr[i] + i; end return s; endfunction
endpackage
module top; int x = pk::f(); endmodule
