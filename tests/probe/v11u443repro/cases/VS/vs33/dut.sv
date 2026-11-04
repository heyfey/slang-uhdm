// § elabProgMemberArrLoopVar443
typedef enum {A, B} e_t; typedef struct packed { e_t f; logic g; } s_t;
module top; prg p(); endmodule
program prg;
s_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
