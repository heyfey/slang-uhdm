// § implicitNetOnePerName405
module top ();
  int a[4];
  int b[4];
  initial begin
    foreach (a[i]) a[i] = i;
    foreach (b[i]) b[i] = i + 1;
  end
endmodule
