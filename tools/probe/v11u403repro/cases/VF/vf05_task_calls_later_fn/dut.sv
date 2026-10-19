// § unitFwdCallNoLink403
task t(output int o); o = f(4); endtask
function int f(int y); return y + 1; endfunction
module top; int r; initial t(r); endmodule
