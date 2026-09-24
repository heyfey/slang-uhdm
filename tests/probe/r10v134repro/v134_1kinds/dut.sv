// r10v134 grid 1 — ARRAY KINDS x KEY TYPES under an indexed-then-member loop list.
package kpk1;

  typedef enum { EA, EB, EC } ecol_t;

  class Leaf1;
    int lq[$];
    int ld[];
    int lf[6];
    int lg[2][3];
    string ls;
    int las[string];
  endclass

  class Holder1;
    Leaf1 hq[$];            // queue
    Leaf1 hd[];             // dynamic
    Leaf1 hf[4];            // fixed 1-D
    Leaf1 hg[2][3];         // fixed 2-D
    Leaf1 hstr[string];     // assoc keyed by string
    Leaf1 hint[int];        // assoc keyed by int
    Leaf1 henum[ecol_t];    // assoc keyed by enum
    Leaf1 hcls[Leaf1];      // assoc keyed by class handle

    function void k_queue();    foreach (hq[u1])   foreach (hq[u1].lq[u2])   $display(u2); endfunction
    function void k_dyn();      foreach (hd[u3])   foreach (hd[u3].ld[u4])   $display(u4); endfunction
    function void k_fix();      foreach (hf[u5])   foreach (hf[u5].lf[u6])   $display(u6); endfunction
    function void k_fix2();     foreach (hg[u7,u8]) foreach (hg[u7][u8].lf[u9]) $display(u9); endfunction
    function void k_str();      foreach (hstr[ua]) foreach (hstr[ua].ld[ub]) $display(ub); endfunction
    function void k_int();      foreach (hint[uc]) foreach (hint[uc].lq[ud]) $display(ud); endfunction
    function void k_enum();     foreach (henum[ue]) foreach (henum[ue].lf[uf]) $display(uf); endfunction
    function void k_cls();      foreach (hcls[ug]) foreach (hcls[ug].ld[uh]) $display(uh); endfunction
    // element member is itself an ASSOC array
    function void k_elemassoc(); foreach (hq[ui]) foreach (hq[ui].las[uj]) $display(uj); endfunction
    // element member is a STRING (iterated over characters)
    function void k_elemstr();  foreach (hd[uk]) foreach (hd[uk].ls[ul]) $display(ul); endfunction
    // element member is a 2-D fixed array, TWO loop vars
    function void k_elem2d();   foreach (hf[um]) foreach (hf[um].lg[un,uo]) $display(un,uo); endfunction
  endclass

endpackage
