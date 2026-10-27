// § elabProgMemberArrLoopVar443
int i;
module top; prg p(); endmodule
program prg;
int a[4];
initial foreach (a[i]) a[i] = i;
endprogram
