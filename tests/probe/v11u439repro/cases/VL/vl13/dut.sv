// § loopVarReadBindsModuleDecl439
module top;
int i;
int arr[4];
final foreach (arr[i]) $display("%0d", arr[i] + i);
endmodule
