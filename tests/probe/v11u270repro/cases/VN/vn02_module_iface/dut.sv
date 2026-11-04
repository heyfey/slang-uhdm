// § methArgPathIdxAtHierPath270
package p;
  class info; int k; function int get(); return k; endfunction endclass
  class holder;
    info a[$];
    function bit has(int x); return 1; endfunction
  endclass
endpackage
interface ifc;
  import p::*;
  holder h;
  int r;
  function automatic void t(int i);
    if (h.has(h.a[i].get())) r = 1;
  endfunction
endinterface
module top;
  import p::*;
  holder h;
  int r;
  ifc u();
  initial begin
    for (int i = 0; i < 2; i++)
      if (h.has(h.a[i].k)) r = i;
  end
  always_comb begin
    automatic int j = r;
    r = h.has(h.a[j].get()) ? 1 : 0;
  end
endmodule
