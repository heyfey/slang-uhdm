// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
int s;
initial begin int la[3]; foreach (la[i]) s = s + i; end
endprogram
