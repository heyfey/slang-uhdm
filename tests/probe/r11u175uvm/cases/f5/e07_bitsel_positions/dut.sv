package p1;
  class leaf; int v; int arr[4]; endclass
  class mid; leaf lf; leaf lfs[4]; int w[4]; endclass
  class top_c;
    mid m;
    mid ms[4];
    function int get(int i, int j, int k);
      int r;
      r = ms[i].w[0];
      r = m.lfs[j].v;
      r = m.w[k];
      return r;
    endfunction
  endclass
endpackage
module top;
  import p1::*;
  top_c t;
  initial begin t = new; void'(t.get(0, 1, 2)); end
endmodule
