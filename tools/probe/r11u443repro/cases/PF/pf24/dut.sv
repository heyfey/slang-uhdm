// § elabProgLoopVarReadBinds443
module top; prg p(); endmodule
program prg;
int arr[4];
function int g(int x); return x; endfunction
initial foreach (arr[i]) arr[i] = g(i) + i;
endprogram
