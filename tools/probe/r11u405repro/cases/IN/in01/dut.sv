// § implicitNetOnePerName405
module top ();
  task automatic t (int n);
    int a[] = new [n];
    foreach (a[i]) a[i] = i;
    foreach (a[i]) $display("%d", a[i]);
  endtask
  initial t(4);
endmodule
