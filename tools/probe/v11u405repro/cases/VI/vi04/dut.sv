// § implicitNetOnePerName405
module top ();
  int a[2][3];
  initial begin
    foreach (a[i, j]) a[i][j] = i + j;
    foreach (a[i, j]) $display("%d", a[i][j]);
  end
endmodule
