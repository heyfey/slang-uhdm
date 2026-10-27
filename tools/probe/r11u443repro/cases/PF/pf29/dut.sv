// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
logic [3:0] v; string str; int s;
initial begin foreach (v[i]) s = s + i; foreach (str[j]) s = s + j; end
endprogram
