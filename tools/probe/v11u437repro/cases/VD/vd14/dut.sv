// § dynArrNewElemLvalueBase437
module sub;
int d[2][];
initial d[0] = new[2];
endmodule
module top; sub u1(); sub u2(); endmodule
