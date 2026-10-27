// § pkgSubLoopVarReadBindsDecl445
package pk;
int g;
task automatic t(input int i); int arr[4]; foreach (arr[i]) g = g + i; endtask
endpackage
module top; initial pk::t(1); endmodule
