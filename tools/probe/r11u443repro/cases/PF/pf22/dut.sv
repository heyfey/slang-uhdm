// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
string sq[$];
int s;
initial foreach (sq[k]) s = s + k;
endprogram
