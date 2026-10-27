// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
logic [3:0] v;
int s;
initial begin : nb int j; foreach (v[j]) s = s + j; end
endprogram
