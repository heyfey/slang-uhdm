// § progStructNetElemKeeps443v
module top; prg p(); endmodule
program prg;
typedef struct packed { logic [3:0] f; } s_t;
s_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
