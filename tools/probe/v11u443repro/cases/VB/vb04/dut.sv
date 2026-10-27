// § elabProgLoopVarReadBinds443
package pk; int pa[3]; endpackage
module top; prg p(); endmodule
program prg;
int s;
initial foreach (pk::pa[i]) s = s + i;
endprogram
