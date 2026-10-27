// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int a[4]; int s;
final foreach (a[i]) s = s + a[i] * i;
endprogram
