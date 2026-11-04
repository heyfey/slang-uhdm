// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int a[2][3];
initial foreach (a[i]) foreach (a[i][j]) a[i][j] = i * j;
endprogram
