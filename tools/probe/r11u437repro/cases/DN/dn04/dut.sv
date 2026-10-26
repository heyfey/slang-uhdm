// § dynArrNewElemLvalueBase437
module top;
task automatic t(); int d[2][]; d[0] = new[3]; endtask
initial t();
endmodule
