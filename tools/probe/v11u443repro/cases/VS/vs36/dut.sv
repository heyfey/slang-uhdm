// § progStructNetElemKeeps443v
module top; prg p(); endmodule
program prg;
wire [3:0] a [3]; int s;
initial foreach (a[i]) s = s + i;
endprogram
