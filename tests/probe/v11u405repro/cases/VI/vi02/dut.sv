// § implicitNetOnePerName405
module top ();
  int a[4], b[3];
  initial begin
    foreach (a[i]) a[i] = i;
    foreach (b[j]) b[j] = j;
    foreach (a[i]) $display("%d", a[i]);
  end
endmodule
