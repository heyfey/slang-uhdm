// § elabProgMemberArrLoopVar443
typedef struct { logic b; int a; } s_t;
module top; prg p(); endmodule
program prg;
s_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
