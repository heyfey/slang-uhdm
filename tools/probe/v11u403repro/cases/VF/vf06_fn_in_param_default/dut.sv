// § unitFwdCallNoLink403
function int g(int a); return f(a); endfunction
function int f(int y); return y + 1; endfunction
module top #(parameter int P = g(3)); int r = P; endmodule
