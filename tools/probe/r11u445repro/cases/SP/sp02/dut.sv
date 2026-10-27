// § foreachLoopVarShadowDeclTs445
module top; prg p(); endmodule
program prg;
int arr[4];
int s;
initial begin : nb int i; foreach (arr[i]) s = s + i; end
endprogram
