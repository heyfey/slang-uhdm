// § progStructNetElemKeeps443v
typedef struct packed { reg [1:0] f; } s_t;
module top; prg p(); endmodule
program prg;
s_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
