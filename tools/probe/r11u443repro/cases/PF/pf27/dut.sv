// § elabProgMemberArrLoopVar443
module top;
int marr[4];
prg p();
endmodule
program prg;
initial foreach (top.marr[i]) top.marr[i] = i;
endprogram
