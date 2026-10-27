// § progStructNetElemKeeps443v
typedef union { int f; shortint g; } u_t;
module top; prg p(); endmodule
program prg;
u_t a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
