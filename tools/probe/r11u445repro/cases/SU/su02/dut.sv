// § foreachLoopVarShadowDeclTs445
module top; endmodule
interface ifc;
int arr[4];
int s;
initial begin int i; foreach (arr[i]) s = s + i; end
endinterface
