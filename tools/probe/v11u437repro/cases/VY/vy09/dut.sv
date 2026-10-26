// § dynArrNewElemLvalueBase437
module top;
int d[2][];
initial begin d[0] = new[2]; d[1] = d[0]; d[0][1] = 5; end
endmodule
