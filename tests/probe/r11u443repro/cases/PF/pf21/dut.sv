// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int aa[int];
int s;
initial foreach (aa[k]) s = s + k;
endprogram
