// § incDecMemberSelIsLvalue184: inc/dec of this- and super-rooted member selects (the law's exclusion), a two-dimensional member select and a handle member select in class methods
package pk;
  typedef struct { int a [2][3]; int b [4]; } s_t;
  class base;
    s_t bs;
  endclass
  class der extends base;
    s_t ds;
    der nxt;
    function void tick(int i, int j);
      this.ds.b[i]++;
      super.bs.b[j]--;
      ds.a[i][j]++;
      ++nxt.ds.b[i];
      bs.a[j][i]--;
    endfunction
  endclass
endpackage
module top; endmodule
