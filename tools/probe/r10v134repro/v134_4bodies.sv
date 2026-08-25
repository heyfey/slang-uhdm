// r10v134 grid 4 — BODY SHAPES under one fixed loop-list shape, plus 1-3 instances.
package bpk4;

  class Cell4;
    int cvals[$];
    int cgrid[2][2];
    int cnum;
    function int cget(); return cnum; endfunction
    function void cset(int v); cnum = v; endfunction
  endclass

  class Sheet4;
    Cell4 scells[$];

    // body reads the ELEMENT's member
    function void b_member();  foreach (scells[t1]) foreach (scells[t1].cvals[t2]) $display(scells[t1].cvals[t2]); endfunction
    // body CALLS the element's method
    function void b_call();    foreach (scells[t3]) foreach (scells[t3].cvals[t4]) $display(scells[t3].cget()); endfunction
    // body reads the ELEMENT itself
    function void b_elem();    foreach (scells[t5]) foreach (scells[t5].cvals[t6]) $display(scells[t5]); endfunction
    // body reads the INDEX only
    function void b_index();   foreach (scells[t7]) foreach (scells[t7].cvals[t8]) $display(t8); endfunction
    // body WRITES the element
    function void b_write();   foreach (scells[t9]) foreach (scells[t9].cvals[ta]) scells[t9].cvals[ta] = ta; endfunction
    // body writes THROUGH a method
    function void b_writem();  foreach (scells[tb]) foreach (scells[tb].cvals[tc]) scells[tb].cset(tc); endfunction
    // body is a NESTED foreach over the element's own array
    function void b_nested();
      foreach (scells[td])
        foreach (scells[td].cvals[te])
          foreach (scells[td].cgrid[tf,tg])
            $display(te, tf, tg);
    endfunction
    // empty-ish body
    function void b_empty();   foreach (scells[th]) foreach (scells[th].cvals[ti]) begin end endfunction
  endclass

  // THREE instances of the very same shape in one scope
  class Trio4;
    Cell4 xa[$], xb[$], xc[$];
    function void three();
      foreach (xa[v1]) foreach (xa[v1].cvals[v2]) $display(v2);
      foreach (xb[v3]) foreach (xb[v3].cvals[v4]) $display(v4);
      foreach (xc[v5]) foreach (xc[v5].cvals[v6]) $display(v6);
    endfunction
  endclass

endpackage
