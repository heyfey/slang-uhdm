// r10uvm134 grid D — BODY SHAPES under the indexed-root loop list.
package qd134;

  class Twig;
    int tv[];
    int tw[string];
    function int leaf(); return 7; endfunction
  endclass

  class Branch;
    Twig twigs[];
    int  seen[Twig];

    // element MEMBER READ
    function void b_memread();
      foreach (twigs[d1]) foreach (twigs[d1].tv[d2]) $display(twigs[d1].tv[d2]);
    endfunction
    // element METHOD CALL
    function void b_method();
      foreach (twigs[d3]) foreach (twigs[d3].tw[d4]) $display(twigs[d3].leaf());
    endfunction
    // element READ (whole handle)
    function void b_elemread();
      foreach (twigs[d5]) foreach (twigs[d5].tv[d6]) seen[twigs[d5]] = 1;
    endfunction
    // INDEX ONLY
    function void b_idxonly();
      foreach (twigs[d7]) foreach (twigs[d7].tw[d8]) $display(d8);
    endfunction
    // NESTED foreach in the body
    function void b_nested();
      foreach (twigs[d9]) foreach (twigs[d9].tv[da]) foreach (twigs[d9].tw[db]) $display(db);
    endfunction
    // EMPTY body
    function void b_empty();
      foreach (twigs[dc]) foreach (twigs[dc].tv[dd]) begin end
    endfunction
    // BEGIN/END body with a label
    function void b_block();
      foreach (twigs[de]) foreach (twigs[de].tw[df]) begin : lbl134
        $display(df);
      end : lbl134
    endfunction
  endclass

endpackage
