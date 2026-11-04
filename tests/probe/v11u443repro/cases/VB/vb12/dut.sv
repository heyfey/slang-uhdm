// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
int a[3]; int s;
initial foreach (a[i]) s += i;
endprogram
