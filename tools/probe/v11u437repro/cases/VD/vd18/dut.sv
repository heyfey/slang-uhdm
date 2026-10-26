// § dynArrNewElemLvalueBase437
module top;
int d[2][];
task automatic t(int k); d[k] = new[k+1]; endtask
initial t(1);
endmodule
