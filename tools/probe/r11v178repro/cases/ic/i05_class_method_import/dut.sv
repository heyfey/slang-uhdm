// § importCloneBodyLocalCopies175
package p1;
  class base;
    int q;
    function int g(int n);
      int loc[2];
      int t = n;
      loc[0] = t;
      return loc[0] + q;
    endfunction
    task run();
      bit done = 0;
      int cnt[4];
      cnt[0] = 1;
    endtask
  endclass
endpackage
package p2;
  import p1::*;
  class d extends base; endclass
endpackage
module top; import p2::*; d x; initial begin x = new; void'(x.g(1)); end endmodule
