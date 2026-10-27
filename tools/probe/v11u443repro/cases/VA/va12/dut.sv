// § elabProgMemberArrLoopVar443
module mid; prg p(); endmodule
module top; mid m1(); mid m2(); endmodule
program prg;
int a[4];
initial foreach (a[i]) a[i] = i;
endprogram
