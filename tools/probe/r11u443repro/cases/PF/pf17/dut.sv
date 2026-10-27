// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
typedef int a_t [3];
a_t ta;
initial foreach (ta[i]) ta[i] = i;
endprogram
