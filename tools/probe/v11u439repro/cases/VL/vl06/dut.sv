// § loopVarReadBindsModuleDecl439
module top;
typedef int i;
int arr[4];
initial foreach (arr[i]) arr[i] = 1;
endmodule
