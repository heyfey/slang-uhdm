// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
byte b[4]; int s;
initial foreach (b[i]) s = s + i;
endprogram
