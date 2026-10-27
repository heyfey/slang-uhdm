// § progStructNetElemKeeps443v
typedef struct packed { logic [3:0] f; } s_t;
module top; prg p(); endmodule
program prg;
s_t a[3];
initial foreach (a[i]) a[i].f = i;
endprogram
