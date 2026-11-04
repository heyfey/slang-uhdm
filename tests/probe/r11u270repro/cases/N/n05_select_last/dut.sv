// § methArgPathIdxAtHierPath270
package p;
  class info;
    int addr[4];
    int k;
  endclass
  class holder;
    int m[int];
    info arr[4];
    function bit has(int a);
      return 1;
    endfunction
    function bit cmp(int a, info b);
      return 1;
    endfunction
  endclass
  class w;
    holder v;
    info x;
    int r;
    function void t(int i, int j);
      if (!v.m.exists(x.addr[i])) r = 0;
      if (v.has(x.addr[j])) r = 1;
      if (v.cmp(0, v.arr[i])) r = 2;
      if (v.has(v.arr[j].k)) r = 3;
      if (v.has(v.arr[i].addr[j])) r = 4;
    endfunction
  endclass
endpackage
module top;
endmodule
