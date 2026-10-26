// § dynArrNewElemLvalueBase437
module top;
int d[3][];
initial for (int i = 0; i < 3; i++) d[i] = new[i+1];
endmodule
