// § loopVarReadBindsModuleDecl439
module top;
int arr[4];
task automatic t(input int i); foreach (arr[i]) arr[i] = i; endtask
initial t(1);
endmodule
