// § methArgPathIdxAtHierPath270
package p;
  class info;
    info nxt[2];
    function string get_name(); return "n"; endfunction
  endclass
  class holder;
    info arr[4];
    function bit exists(string a);
      return 1;
    endfunction
    task do_it(string a);
    endtask
  endclass
  class w;
    holder v;
    int r;
    extern function void t(int i, int j);
    task u(int i);
      if (this.v.exists(this.v.arr[i].get_name())) r = 1;
      v.do_it(v.arr[i].get_name());
    endtask
  endclass
  function void w::t(int i, int j);
    if (v.exists(v.arr[i].nxt[j].get_name())) r = 2;
    if (v.exists(v.arr[i + j].get_name())) r = 3;
  endfunction
endpackage
module top;
endmodule
