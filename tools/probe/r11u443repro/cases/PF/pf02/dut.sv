// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
logic [7:0] v;
initial foreach (v[i]) v[i] = 1'b0;
endprogram
