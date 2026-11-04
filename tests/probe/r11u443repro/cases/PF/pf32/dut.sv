// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
int arr[4];
int i;
int s;
initial foreach (arr[i]) s = s + i;
endprogram
