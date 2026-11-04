// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
task automatic t; begin int i; foreach (arr[i]) arr[i] = i; end endtask
endmodule
