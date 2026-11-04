// § foreachTrailSkipDropped439
module top;
int a[2][3];
int b[2][3];
initial begin
  foreach (a[i, ]) a[i][0] = i;
  foreach (b[i, j]) b[i][j] = i;
end
endmodule
