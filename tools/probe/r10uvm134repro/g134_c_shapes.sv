// r10uvm134 grid C — the LOOP LIST SHAPE grid: where the first index select
// falls decides ref_var vs hier_path and WHICH name survives.
package qc134;

  class Pebble;
    int pv[];
    int pw[string];
    Pebble pnext;
  endclass

  class Rock;
    Pebble rs[];
    Pebble rone;
    int rv[];
  endclass

  class Boulder;
    Rock bigs[];
    Rock solo;
    int flat[];
    int grid2[4][5];

    // 1 bare
    function void s_bare();          foreach (flat[z1]) $display(z1); endfunction
    // 2 bare 2-dim
    function void s_twodim();        foreach (grid2[z2, z3]) $display(z2, z3); endfunction
    // 3 this. bare
    function void s_thisbare();      foreach (this.flat[z4]) $display(z4); endfunction
    // 4 pure dotted 2 segments
    function void s_dot2();          foreach (solo.rv[z5]) $display(z5); endfunction
    // 5 pure dotted 3 segments
    function void s_dot3();          foreach (solo.rone.pv[z6]) $display(z6); endfunction
    // 6 INDEXED ROOT then member   -> ref_var of the ROOT
    function void s_idxdot();
      foreach (bigs[z7]) foreach (bigs[z7].rv[z8]) $display(z8);
    endfunction
    // 7 INDEXED ROOT, member, indexed, member (3 deep)
    function void s_idxdot3();
      foreach (bigs[z9]) foreach (bigs[z9].rs[za]) foreach (bigs[z9].rs[za].pw[zb]) $display(zb);
    endfunction
    // 8 DOTTED root, indexed member, then member -> hier_path of the PREFIX
    function void s_dotidxdot();
      foreach (solo.rs[zc]) foreach (solo.rs[zc].pv[zd]) $display(zd);
    endfunction
    // 9 this. root, indexed, member -> ref_var of the FIRST name after this
    function void s_thisidxdot();
      foreach (this.bigs[ze]) foreach (this.bigs[ze].rv[zf]) $display(zf);
    endfunction
    // 10 this. dotted, indexed member, member -> hier_path of the prefix
    function void s_thisdotidxdot();
      foreach (this.solo.rs[zg]) foreach (this.solo.rs[zg].pv[zh]) $display(zh);
    endfunction
    // 11 LOCAL array, indexed root, member
    function void s_localidxdot();
      Rock mine[];
      foreach (mine[zi]) foreach (mine[zi].rv[zj]) $display(zj);
    endfunction
    // 12 FORMAL array, indexed root, member
    function void s_formalidxdot(ref Rock arg[$]);
      foreach (arg[zk]) foreach (arg[zk].rv[zl]) $display(zl);
    endfunction
  endclass

endpackage
