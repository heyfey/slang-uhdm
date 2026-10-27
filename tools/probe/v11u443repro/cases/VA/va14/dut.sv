// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int a[3]; int b[2]; int s;
initial foreach (a[i]) foreach (b[j]) s = s + i * j;
endprogram
