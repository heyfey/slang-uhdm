// § loopVarReadBindsModuleDecl439
module top;
parameter int i = 2;
int arr[4];
initial foreach (arr[i]) arr[i] = i;
endmodule
