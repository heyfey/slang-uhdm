// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
logic [7:0] v; int s;
initial foreach (v[i]) s = s + i;
endprogram
