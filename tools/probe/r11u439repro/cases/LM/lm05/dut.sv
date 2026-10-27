// § loopVarReadBindsModuleDecl439
module top;
int i;
int arr[4];
initial begin int i; foreach (arr[i]) arr[i] = i; end
endmodule
