// § loopVarReadBindsModuleDecl439
module sub;
int i;
int arr[4];
initial foreach (arr[i]) arr[i] = i;
endmodule
module top; sub u1(); sub u2(); endmodule
