// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int s;
task automatic t(ref int i); foreach (arr[i]) s = s + i; endtask
endmodule
