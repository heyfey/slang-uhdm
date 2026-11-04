// § emptyConcatArrayVar413
module top;
  int q[$];
  int n;
  task automatic t(int a[$]);
    n = a.size();
  endtask
  initial t({});
endmodule
