// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
logic [3:0][1:0] pv; int s;
initial foreach (pv[i, j]) s = s + i + j;
endprogram
