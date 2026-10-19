// § unitFwdCallNoLink403
function int h(int y); return y * 2; endfunction
function int g(int a); return h(a) + f(a, 3); endfunction
function int f(int y, int z); return y + z; endfunction
module top; int r; initial r = g(1); endmodule
