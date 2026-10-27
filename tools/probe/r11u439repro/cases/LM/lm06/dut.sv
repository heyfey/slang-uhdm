// § loopVarReadBindsModuleDecl439
module top;
int i, j;
int arr2[2][3];
initial foreach (arr2[i, j]) arr2[i][j] = i * j;
endmodule
