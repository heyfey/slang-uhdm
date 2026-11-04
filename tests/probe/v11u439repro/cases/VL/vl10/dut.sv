// § loopVarReadBindsModuleDecl439
module top;
int i, j;
int arr[2][3];
always_comb foreach (arr[i, j]) arr[i][j] = i + j;
endmodule
