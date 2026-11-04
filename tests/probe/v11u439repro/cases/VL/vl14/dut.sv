// § loopVarReadBindsModuleDecl439
module top;
logic [3:0] i;
int arr[2][2];
initial foreach (arr[i]) foreach (arr[i][j]) arr[i][j] = i * j;
endmodule
