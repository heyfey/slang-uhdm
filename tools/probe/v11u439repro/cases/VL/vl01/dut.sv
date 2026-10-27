// § loopVarReadBindsModuleDecl439
interface ifc;
int i;
int arr[4];
initial foreach (arr[i]) arr[i] = i;
endinterface
module top;
ifc u();
endmodule
