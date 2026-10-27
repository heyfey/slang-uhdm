// § elabProgMemberArrLoopVar443
class K; endclass
module top; prg p(); endmodule
program prg;
int ka[K];
int s;
initial foreach (ka[k]) s = s + 1;
endprogram
