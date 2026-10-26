// § dynArrNewElemLvalueBase437
module top;
function automatic void f(ref int d[2][]); d[0] = new[2]; endfunction
int x[2][];
initial f(x);
endmodule
