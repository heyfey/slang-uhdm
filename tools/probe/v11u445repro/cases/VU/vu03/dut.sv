// § foreachLoopVarShadowDeclTs445
module top; endmodule
interface ifc;
int arr[4]; int s;
task automatic t; begin int i; foreach (arr[i]) s = s + i; end endtask
endinterface
