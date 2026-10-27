// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
logic [3:0] m [2];
initial foreach (m[i]) m[i] = 4'(i);
endprogram
