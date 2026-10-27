// § elabProgMemberArrLoopVar443
typedef struct { int q[2]; } s_t;
module top; prg p(); endmodule
program prg;
s_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
