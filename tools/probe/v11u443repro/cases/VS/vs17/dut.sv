// § elabProgMemberArrLoopVar443
typedef struct packed { logic [3:0] f; } s_t;
module top; prg p(); endmodule
program prg;
s_t [1:0] a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
