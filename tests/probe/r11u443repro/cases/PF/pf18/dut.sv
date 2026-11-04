// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg(input logic [3:0] pin);
int s;
initial foreach (pin[i]) s = s + i;
endprogram
