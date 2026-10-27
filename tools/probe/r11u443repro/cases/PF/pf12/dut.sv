// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
string str;
int s;
initial foreach (str[k]) s = s + k;
endprogram
