// § foreachLoopVarShadowDeclTs445
module top; prg p(); endmodule
program prg;
int arr[4];
int s;
initial fork int i; foreach (arr[i]) s = s + i; join
endprogram
