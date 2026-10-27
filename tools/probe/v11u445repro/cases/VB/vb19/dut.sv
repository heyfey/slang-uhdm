// § foreachLoopVarShadowDeclTs445
interface ifc;
int arr[4]; int s;
initial begin int i; foreach (arr[i]) s = s + i; end
endinterface
module top; ifc u1(); ifc u2(); endmodule
