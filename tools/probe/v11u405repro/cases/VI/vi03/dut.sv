// § implicitNetOnePerName405
module top ();
  int a[4];
  task automatic t1; foreach (a[i]) a[i] = i; endtask
  task automatic t2; foreach (a[i]) $display("%d", a[i]); endtask
  initial begin t1; t2; end
endmodule
