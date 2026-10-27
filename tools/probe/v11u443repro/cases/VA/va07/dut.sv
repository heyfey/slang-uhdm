// § elabProgMemberArrLoopVar443
module top; logic c; prg p(.clk(c)); endmodule
program prg(input logic clk);
int a[4];
initial foreach (a[i]) a[i] = i;
endprogram
