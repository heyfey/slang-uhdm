// § pkgSubLoopVarReadBindsDecl445
package pk;
int g;
task automatic t(); int arr[4]; int i; fork foreach (arr[i]) g = g + i; join endtask
endpackage
module top; initial pk::t(); endmodule
