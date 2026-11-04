// § methArgPathIdxAtHierPath270
package p;
  class info;
    int k;
    function string get_name(); return "n"; endfunction
    function int get_k(int a); return a; endfunction
  endclass
  class holder;
    info sva_info[$];
    function bit exists(string a, string b = "");
      return 1;
    endfunction
    function bit has(int a);
      return 1;
    endfunction
  endclass
  function automatic bit pf(string a);
    return 1;
  endfunction
  class w;
    holder v;
    string s;
    int r;
    function void t(int index, int j);
      s = v.sva_info[index].get_name();
      if (pf(v.sva_info[j].get_name())) r = 0;
      if (v.has(v.sva_info[index].k)) r = 1;
      if (v.has(v.sva_info[j].get_k(index))) r = 2;
      if (v.exists(v.sva_info[index + 1].get_name())) r = 3;
      if (v.exists(v.sva_info[j].get_name(), "x")) r = 4;
    endfunction
  endclass
endpackage
module top;
endmodule
