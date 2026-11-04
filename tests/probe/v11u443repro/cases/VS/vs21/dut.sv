// § elabProgMemberArrLoopVar443
typedef struct packed { bit [1:0] a; logic [1:0] b; } s_t;
module top; prg p(); endmodule
program prg;
s_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
