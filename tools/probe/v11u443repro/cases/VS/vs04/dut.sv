// § elabProgMemberArrLoopVar443
typedef enum {A, B} e_t;
module top; prg p(); endmodule
program prg;
e_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
