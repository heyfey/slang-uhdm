// § loopVarReadBindsModuleDecl439
module top;
int arr[4];
initial begin : nb int i; foreach (arr[i]) arr[i] = i; end
endmodule
