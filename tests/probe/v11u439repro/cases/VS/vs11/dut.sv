// § foreachTrailSkipDropped439
module top;
int a[2][3];
task automatic t(); foreach (a[i, ]) a[i][0] = i; endtask
initial t();
endmodule
