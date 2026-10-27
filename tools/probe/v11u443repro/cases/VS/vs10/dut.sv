// § elabProgMemberArrLoopVar443
typedef union packed { logic [3:0] f; logic [3:0] g; } u_t;
module top; prg p(); endmodule
program prg;
u_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
