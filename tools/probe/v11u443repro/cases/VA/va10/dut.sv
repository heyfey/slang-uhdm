// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int a[2][3];
initial foreach (a[, j]) a[0][j] = j;
endprogram
