// § loopVarReadBindsModuleDecl439
module top;
int arr[4];
initial foreach (arr[i]) arr[i] = i;
logic [7:0] i;
endmodule
