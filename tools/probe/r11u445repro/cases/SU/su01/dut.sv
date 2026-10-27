// § foreachLoopVarShadowDeclTs445
module top; endmodule
program prg;
int arr[4];
int s;
initial begin int i; foreach (arr[i]) s = s + i; end
endprogram
