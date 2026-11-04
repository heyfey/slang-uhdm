// § loopVarReadBindsModuleDecl439
module top;
logic [1:0] i;
int arr[4];
int j;
initial begin foreach (arr[i]) arr[i] = i; foreach (arr[j]) arr[j] = j; end
endmodule
