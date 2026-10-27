// § elabProgMemberArrLoopVar443
typedef int i_t;
module top; prg p(); endmodule
program prg;
i_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
