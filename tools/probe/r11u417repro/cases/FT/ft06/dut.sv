// § foreachArrayNamesTypedef417
module top;
  typedef bit [1:0] b;
  int n;
  task automatic t();
    int b[4];
    foreach (b[i]) n += i;
  endtask
  initial t();
endmodule
