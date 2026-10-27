// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int a[2][3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
