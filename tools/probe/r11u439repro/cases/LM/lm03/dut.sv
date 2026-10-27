// § loopVarReadBindsModuleDecl439
module top;
wire [3:0] k;
int arr[4];
initial foreach (arr[k]) arr[k] = k;
endmodule
