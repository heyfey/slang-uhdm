// § elabProgMemberArrLoopVar443
typedef struct packed { logic [1:0] f; } i_t; typedef struct packed { i_t [1:0] in; } s_t;
module top; prg p(); endmodule
program prg;
s_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
