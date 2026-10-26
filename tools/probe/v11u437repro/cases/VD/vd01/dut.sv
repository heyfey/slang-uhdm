// § dynArrNewElemLvalueBase437
module top;
function automatic int f(); int d[2][]; d[0] = new[3]; return d[0].size(); endfunction
int r;
initial r = f();
endmodule
