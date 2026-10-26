// § dynArrNewElemLvalueBase437
module top;
int d[][];
initial begin d = new[2]; d[0] = new[3]; d[1] = new[3](d[0]); end
endmodule
