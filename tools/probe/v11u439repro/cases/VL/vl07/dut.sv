// § loopVarReadBindsModuleDecl439
module sub #(parameter N = 4);
int i;
int arr[N];
initial foreach (arr[i]) arr[i] = i;
endmodule
module top;
sub #(2) a();
sub #(3) b();
endmodule
