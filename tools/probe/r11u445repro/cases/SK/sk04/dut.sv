// § foreachLoopVarShadowDeclTs445
package pk;
int g;
task automatic t(); int arr[4]; begin int i; foreach (arr[i]) g = g + i; end endtask
endpackage
module top; initial pk::t(); endmodule
