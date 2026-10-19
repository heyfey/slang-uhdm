// § implicitNetOnePerName405
module top ();
  int a[4];
  initial begin
    foreach (a[i]) a[i] = i;
    foreach (a[j]) $display("%d", a[j]);
  end
endmodule
