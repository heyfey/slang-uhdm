// § foreachArrayNamesClass417
module top;
  class b;
    int v;
  endclass
  int c[3];
  int n;
  task automatic t();
    int b[2];
    foreach (b[i]) n += i;
  endtask
  initial t();
endmodule
