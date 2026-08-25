// r10v134 grid 2 — HOMES.  The same indexed-then-member loop list written in
// eight different homes, with deliberately unalike names.
package hpk2;

  class Twig2;
    int wa[$];
    int wb[];
    function int mcount(); return wa.size(); endfunction
  endclass

  class Branch2;
    Twig2 bnodes[$];
    extern function void oob_body();
    function void in_body();  foreach (bnodes[p1]) foreach (bnodes[p1].wa[p2]) $display(p2); endfunction
    static function void st_body(); Twig2 loc2[$]; foreach (loc2[p3]) foreach (loc2[p3].wb[p4]) $display(p4); endfunction
  endclass

  function void Branch2::oob_body();
    foreach (bnodes[p5]) foreach (bnodes[p5].wb[p6]) $display(p6);
  endfunction

  Twig2 pkgtwigs[4];

  function void free_fn2();
    foreach (pkgtwigs[p7]) foreach (pkgtwigs[p7].wa[p8]) $display(p8);
  endfunction

  task free_task2();
    foreach (pkgtwigs[p9]) foreach (pkgtwigs[p9].wb[pa]) $display(pa);
  endtask

endpackage

module mod2;
  import hpk2::*;
  Twig2 mtwigs[3];
  initial begin
    foreach (mtwigs[pb]) foreach (mtwigs[pb].wa[pc]) $display(pc);
  end
  task mtask2();
    foreach (mtwigs[pd]) foreach (mtwigs[pd].wb[pe]) $display(pe);
  endtask
  function int mfun2();
    foreach (mtwigs[pf]) foreach (mtwigs[pf].wa[pg]) $display(pg);
    return 0;
  endfunction
  always @* begin
    foreach (mtwigs[ph]) foreach (mtwigs[ph].wb[pi]) $display(pi);
  end
endmodule

interface iface2;
  import hpk2::*;
  Twig2 itwigs[2];
  task itask2();
    foreach (itwigs[pj]) foreach (itwigs[pj].wa[pk]) $display(pk);
  endtask
endinterface

program prog2;
  import hpk2::*;
  Twig2 ptwigs[2];
  initial begin
    foreach (ptwigs[pl]) foreach (ptwigs[pl].wb[pm]) $display(pm);
  end
endprogram
