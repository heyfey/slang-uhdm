// v84x1 — NESTING DEPTH and INDEX POSITION beyond the b1 grid.
module v84x1;
  class deep1;
    int    fld;
    int    arr[$];
    int    m2[3][4];
  endclass
  class deep2;
    deep1 a;
    int   fld;
  endclass
  class c1x;
    deep2  b;
    deep1  h;
    deep1  ha[$];
    int    n;
    function void f(int i, int j);
      n = this.b.a.fld;            // L18 3 steps, member
      n = this.b.a.arr.size();     // L19 4 steps + builtin
      n = this.b.a.arr[i];         // L20 3 steps then index
      n = this.h.m2[i][j];         // L21 2 steps then TWO indices
      n = this.ha[i].arr[j];       // L22 index on step 1, then member, then index
      n = this.h.arr[i] + this.b.fld;   // L23 two sites, one line
      n = this.h.arr.size() + this.b.a.fld;  // L24 two sites, mixed
    endfunction
  endclass
endmodule
