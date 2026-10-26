// § dynArrNewElemLvalueBase437
module top;
int d[];
int e[2][];
initial begin d = new[3]; e[0] = d; e[1] = new[1]; end
endmodule
