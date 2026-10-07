// § methArgPathIdxAtHierPath270
package p;
  class leaf; int z; int arr[4]; function int g(); return z; endfunction endclass
  class info;
    int k;
    leaf lf;
    leaf lfs[4];
    function string get_name(); return "n"; endfunction
  endclass
  class holder;
    info sva_info[$];
    info grid[4][4];
    function bit has(int a); return 1; endfunction
    function bit hs(string a); return 1; endfunction
  endclass
  class w;
    holder v;
    int idx[4];
    int r;
    function int gi(int a); return a; endfunction
    function void t(int i, int j);
      if (v.has(v.sva_info[i].lf.z)) r = 1;
      if (v.has(v.grid[i][j].k)) r = 2;
      if (v.has(v.sva_info[idx[i]].k)) r = 3;
      if (v.has(v.sva_info[gi(i)].k)) r = 4;
      if (v.has(v.sva_info[i].lfs[j].z)) r = 5;
      if (v.has(this.v.sva_info[i].k)) r = 6;
      if (v.has(v.sva_info[i].lf.arr[j])) r = 7;
      if (v.hs(v.sva_info[i + j].get_name())) r = 8;
      if (v.has(v.sva_info[i].k + v.sva_info[j].k)) r = 9;
      if (v.has(v.sva_info[i].lf.g())) r = 10;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  w x;
endmodule
