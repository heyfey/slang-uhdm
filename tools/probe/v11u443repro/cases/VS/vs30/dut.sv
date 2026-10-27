// § elabProgMemberArrLoopVar443
typedef enum logic [1:0] {A, B} e_t; typedef struct packed { e_t f; } s_t;
module top; prg p(); endmodule
program prg;
s_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
