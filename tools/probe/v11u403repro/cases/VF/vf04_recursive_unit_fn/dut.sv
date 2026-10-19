// § unitFwdCallNoLink403
function automatic int f(int y); return y == 0 ? 0 : f(y - 1) + 1; endfunction
module top; int r; initial r = f(2); endmodule
