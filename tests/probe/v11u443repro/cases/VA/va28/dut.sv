// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int a[3] = '{1, 2, 3}; int s;
initial foreach (a[i]) s = s + a[i];
endprogram
