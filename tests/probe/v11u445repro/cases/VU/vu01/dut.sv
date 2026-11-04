// § foreachLoopVarShadowDeclTs445
module top; endmodule
program prg;
int arr[4]; int s;
task automatic t; int i; foreach (arr[i]) s = s + i; endtask
endprogram
