// § loopVarReadBindsModuleDecl439
module top(output int i);
int arr[4];
initial foreach (arr[i]) arr[i] = i;
endmodule
