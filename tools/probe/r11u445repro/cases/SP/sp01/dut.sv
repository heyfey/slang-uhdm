// § foreachLoopVarShadowDeclTs445
module top; prg p(); endmodule
program prg;
int arr[4];
int s;
initial begin int i; foreach (arr[i]) s = i; end
endprogram
