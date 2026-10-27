// § progStructNetElemKeeps443v
typedef struct packed { logic [3:0] f; } s_t;
module top; prg p(); endmodule
program prg;
s_t a[$]; int s;
initial foreach (a[i]) s = s + i;
endprogram
