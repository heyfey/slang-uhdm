// § elabProgMemberArrLoopVar443
module top; prg p(); endmodule
program prg;
logic [7:0] mem [4];
initial foreach (mem[i, j]) mem[i][j] = 1'b0;
endprogram
