// § dynArrNewElemLvalueBase437
typedef int da_t[];
module top;
da_t d[2];
initial d[1] = new[2];
endmodule
