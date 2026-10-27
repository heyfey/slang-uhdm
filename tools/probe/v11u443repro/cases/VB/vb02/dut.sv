// § elabProgLoopVarReadBinds443
int ua[3];
module top; prg p(); endmodule
program prg;
int s;
initial foreach (ua[i]) s = s + i;
endprogram
