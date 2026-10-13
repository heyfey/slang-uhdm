// § hpOpIdxNestedSelByPath304
class item; int f; endclass
class grid;
  item iarr[4];
  int midx[4];
  function int probe();
    int i, r;
    r = iarr[midx[i] + 1].f;
    return r;
  endfunction
endclass
module top; endmodule
