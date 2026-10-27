// § progStructNetElemKeeps443v
module top; prg p(); endmodule
program prg;
struct packed { logic [3:0] f; } a[3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
