// § loopVarReadBindsModuleDecl439
module top;
real i;
string s;
int arr[4];
initial foreach (arr[i]) begin arr[i] = i; s = "a"; end
endmodule
