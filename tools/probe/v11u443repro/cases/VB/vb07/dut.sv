// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
string str; int s;
initial begin str = "ab"; foreach (str[i]) s = s + i; end
endprogram
