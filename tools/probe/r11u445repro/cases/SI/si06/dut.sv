// § foreachLoopVarShadowDeclTs445
interface ifc;
logic [3:0] sig;
int s;
int arr[4];
initial begin int i; foreach (arr[i]) s = s + i; end
endinterface
module top; ifc u(); endmodule
