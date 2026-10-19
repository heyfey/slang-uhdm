// § unitFwdCallNoLink403
module top; endmodule
function int g(int a);
return f(a) + 1;
endfunction
function int f(int y);
return y+1;
endfunction
