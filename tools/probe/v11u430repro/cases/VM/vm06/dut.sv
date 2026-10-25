// § modArrConcatInitElemSize430
module top; function int f(); int a[2] = {1, 2}; return a[0]; endfunction
int x; initial x = f(); endmodule
