// § progStructNetElemKeeps443v
typedef struct packed { logic [3:0] f; } s_t;
typedef s_t sa_t [3];
module top; prg p(); endmodule
program prg;
sa_t a [2]; int s;
initial foreach (a[i]) s = s + i;
endprogram
