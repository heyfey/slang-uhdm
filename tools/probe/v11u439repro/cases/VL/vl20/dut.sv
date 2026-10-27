// § loopVarReadBindsModuleDecl439
module top;
int x;
int arr[4];
int s;
initial s = arr.sum(x) with (x * 2);
endmodule
