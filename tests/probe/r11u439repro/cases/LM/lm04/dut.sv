// § loopVarReadBindsModuleDecl439
module top;
int i;
int arr[4];
task automatic t(); foreach (arr[i]) arr[i] = i; endtask
initial t();
endmodule
