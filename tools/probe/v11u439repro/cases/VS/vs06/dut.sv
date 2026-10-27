// § foreachLeadSkipPlaceholder439
module top;
int a[2][3];
int b[4][5];
initial begin
  foreach (a[, j]) a[0][j] = j;
  foreach (b[, k]) b[1][k] = k;
end
endmodule
