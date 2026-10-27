// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
int a[3]; int s;
initial foreach (a[i]) case (i) 0: s = 1; default: s = 2; endcase
endprogram
