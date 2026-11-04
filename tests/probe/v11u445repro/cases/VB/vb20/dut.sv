// § foreachLoopVarShadowDeclTs445
module top;
int arr[4]; int s;
task automatic t(input int i); begin foreach (arr[i]) s = s + i; end endtask
endmodule
