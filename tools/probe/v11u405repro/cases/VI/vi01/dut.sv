// § implicitNetOnePerName405
module top ();
  int a[4];
  initial foreach (a[i]) a[i] = i;
  always @(a[0]) foreach (a[i]) $display("%d", a[i]);
endmodule
