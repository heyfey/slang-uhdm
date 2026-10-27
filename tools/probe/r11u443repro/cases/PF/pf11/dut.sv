// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
int q[$];
int s;
initial foreach (q[k]) s = s + k;
endprogram
