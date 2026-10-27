// § elabProgLoopVarReadBinds443
class C; int arr[3]; endclass
module top; prg p(); endmodule
program prg;
C h; int s;
initial begin h = new; foreach (h.arr[i]) s = s + i; end
endprogram
