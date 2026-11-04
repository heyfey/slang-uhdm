// § unitFwdCallNoLink403
module top; int r; initial r = f(2); endmodule
function int f(int y); return y + 1; endfunction
