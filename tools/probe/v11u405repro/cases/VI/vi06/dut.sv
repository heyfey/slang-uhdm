// § implicitNetOnePerName405
module m ();
  int a[4];
  initial foreach (a[i]) a[i] = i;
endmodule
module top ();
  int b[2];
  m u();
  initial foreach (b[i]) b[i] = i;
  initial foreach (b[i]) b[i] += 1;
endmodule
