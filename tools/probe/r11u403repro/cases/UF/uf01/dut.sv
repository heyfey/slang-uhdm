// § unitFwdCallNoLink403
module top; endmodule
task t;
int x;
x = f(1);
endtask
function int f(int y);
return y+1;
endfunction
