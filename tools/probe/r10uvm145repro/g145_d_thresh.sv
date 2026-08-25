// r10uvm145 arm D — THE BEGIN-WRAPPER THRESHOLD, and the nested-block control.
// A body's declarations decide whether Surelog synthesizes a `begin`:
//   BLOCK-ITEM: the decls ARE body items and count toward "more than 1 stmt";
//   TF-ITEM   : the decls are tf_item_declarations, consumed before the body
//               statement walk starts, and count for nothing.
// N inits x M real statements, both productions, plus INNER begin blocks whose
// own locals are ALWAYS the block-item production however the body is written.
// MEASUREMENT ONLY.
package pd145;

  // ---------- TF-ITEM: N inits x M real statements ----------
  function void n1m0_145;  int a1 = 1;                              endfunction
  // n2m0 (2 inits, 0 statements) SEGFAULTS the PRISTINE binary -> g145_e_zero.sv
  function void n1m1_145;  int a1 = 1; $display(a1);                endfunction
  function void n1m2_145;  int a1 = 1; $display(a1); $display(2);   endfunction
  function void n2m1_145;  int a1 = 1; int a2 = 2; $display(a1+a2); endfunction
  function void n2m2_145;  int a1 = 1; int a2 = 2; $display(a1); $display(a2); endfunction
  function void n0m1_145;  int a1;     $display(a1);                endfunction
  function void n0m2_145;  int a1;     $display(a1); $display(3);   endfunction
  function void n3m1_145;  int a1 = 1, a2 = 2, a3 = 3; $display(a1+a2+a3); endfunction

  // ---------- BLOCK-ITEM twins ----------
  function void p1m0_145(); int b1 = 1;                              endfunction
  function void p1m1_145(); int b1 = 1; $display(b1);                endfunction
  function void p1m2_145(); int b1 = 1; $display(b1); $display(2);   endfunction
  function void p2m0_145(); int b1 = 1; int b2 = 2;                  endfunction
  function void p2m1_145(); int b1 = 1; int b2 = 2; $display(b1+b2); endfunction
  function void p2m2_145(); int b1 = 1; int b2 = 2; $display(b1); $display(b2); endfunction
  function void p0m1_145(); int b1;     $display(b1);                endfunction
  function void p0m2_145(); int b1;     $display(b1); $display(3);   endfunction
  function void p3m1_145(); int b1 = 1, b2 = 2, b3 = 3; $display(b1+b2+b3); endfunction

  // ---------- an INNER begin's locals are block items either way --------
  function void innerNoParen145;
    int outerV = 5;
    begin : nest145
      int innerV = 6;
      $display(innerV + outerV);
    end
    $display(outerV);
  endfunction

  function void innerParen145();
    int outerV = 5;
    begin : nest145b
      int innerV = 6;
      $display(innerV + outerV);
    end
    $display(outerV);
  endfunction

  // ---------- a body that IS one explicit begin -------------------------
  function void bodyBeginNoParen145;
    int bb = 8;
    begin
      $display(bb);
      $display(bb + 1);
    end
  endfunction

  function void bodyBeginParen145();
    int bb = 8;
    begin
      $display(bb);
      $display(bb + 1);
    end
  endfunction

  // ---------- a FOR loop's own variable (a different site) --------------
  function void forVarNoParen145;
    int fv = 0;
    for (int fi = 0; fi < 3; fi++) fv = fv + fi;
    $display(fv);
  endfunction

  function void forVarParen145();
    int fv = 0;
    for (int fi = 0; fi < 3; fi++) fv = fv + fi;
    $display(fv);
  endfunction

endpackage
