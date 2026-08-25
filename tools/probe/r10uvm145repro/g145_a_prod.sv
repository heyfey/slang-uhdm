// r10uvm145 arm A — THE PRODUCTION GRID.  MEASUREMENT ONLY.
// TF-ITEM (paren-less function / task whose body declares io) vs BLOCK-ITEM
// (function with a port-list paren / task with no body io), crossed with
// written lifetime and with 1..3 declarators per declaration statement.
// Names, orders, numbers and case are deliberately UNLIKE each other so an
// arm that AGREES cannot be agreeing for the wrong reason.
package pa145;

  // ---- TF-ITEM: paren-less FUNCTION -------------------------------------
  function void Zed145;          // 1 declarator, literal init
    int qq = 7;
    qq = qq + 1;
    $display(qq);
  endfunction

  function int noParenTwo145;    // 2 declarators in ONE statement, both init
    int aa = 3, bB = 11;
    aa = aa * 2;
    return aa + bB;
  endfunction

  function int noParenThree145;  // 3 declarators, MIDDLE one uninitialised
    int r1 = 5, r2, r3 = 9;
    r2 = r1;
    return r2 + r3;
  endfunction

  function void staticNoParen145;   // written STATIC lifetime
    static int sCount = 42;
    static int sBare;
    sBare = sCount;
    $display(sBare);
  endfunction

  function void autoNoParen145;     // written AUTOMATIC lifetime
    automatic int uVal = 13;
    automatic int uOther;
    uOther = uVal;
    $display(uOther);
  endfunction

  // ---- BLOCK-ITEM: FUNCTION WITH A PORT-LIST PAREN ----------------------
  function void Zed145p();
    int qq = 7;
    qq = qq + 1;
    $display(qq);
  endfunction

  function int parenTwo145();
    int aa = 3, bB = 11;
    aa = aa * 2;
    return aa + bB;
  endfunction

  function int parenThree145();
    int r1 = 5, r2, r3 = 9;
    r2 = r1;
    return r2 + r3;
  endfunction

  function void staticParen145();
    static int sCount = 42;
    static int sBare;
    sBare = sCount;
    $display(sBare);
  endfunction

  function void autoParen145();
    automatic int uVal = 13;
    automatic int uOther;
    uOther = uVal;
    $display(uOther);
  endfunction

  // ---- TASKS: BLOCK-ITEM unless the body declares io --------------------
  task tskNoIo145;               // BLOCK-ITEM (no body io)
    int tn = 21;
    tn = tn - 1;
    $display(tn);
  endtask

  task tskBodyIo145;             // TF-ITEM (body io pushes it back)
    input int inArg;
    int tv = 33;
    tv = tv + inArg;
    $display(tv);
  endtask

  task tskParen145(input int inArg);   // BLOCK-ITEM (ANSI port list)
    int tv = 33;
    tv = tv + inArg;
    $display(tv);
  endtask

  // ---- THRESHOLD cells: how many REAL statements follow the decls -------
  // (the ZERO-statement TF-ITEM cells live in g145_e_zero.sv: on the PRISTINE
  //  binary they SEGFAULT, so they cannot share an arm with scoreable cells.)
  function void oneStmtNoParen145;   // TF-ITEM, 2 inits, ONE real statement
    int h1 = 1;
    int h2 = 2;
    $display(h1 + h2);
  endfunction

  function void oneStmtParen145();   // BLOCK-ITEM twin
    int h1 = 1;
    int h2 = 2;
    $display(h1 + h2);
  endfunction

  function void bareOneStmtNoParen145;  // TF-ITEM, uninitialised local only
    int m1;
    $display(m1);
  endfunction

endpackage
