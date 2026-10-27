// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int aa[string];
int s;
initial foreach (aa[k]) s = s + aa[k];
endprogram
