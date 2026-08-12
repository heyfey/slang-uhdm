// r10uvm57repro/v2_loopvar.sv -- THE VERIFIER'S SECOND ARM: the SYMBOL-KIND and
// ENCLOSING-CONSTRUCT axes.
//
//   X1  the IMPLICIT loop variable of `for (int i = 0; ...)`.  slang wraps such
//       a loop in a StatementBlockSymbol whose name is EMPTY and whose child is
//       the loop variable, so `blkLocalSameCtrlDepth57`'s three tests
//       (Variable + unnamed StatementBlock parent + open at the same depth)
//       can all pass on a LOOP VARIABLE, a symbol kind no arm cell covers.
//   X2  the implicit variable of `foreach (a[j])` -- same question, and §28's
//       own comment names `in_foreach` as a shape that must stay bare.
//   X3  a `for`-BODY block local read in the loop's own body (b2 has a `for`
//       cell but the recorded depth of the implicit wrapper vs the body is the
//       untested half).
//   X4  the SAME shapes at MODULE scope: a module function, a module task, an
//       `initial` block and an `always_comb`.  The gate needs
//       curSubClassScope9, so these must be BYTE-IDENTICAL between the two
//       binaries; that is the assertion, not a guess.
//   X5  a PACKAGE function twin, for the same reason.
package pv2;
  function automatic void sinki(int i); $display(i); endfunction
  function automatic void sink(string s); $display(s); endfunction

  class shp;                       // NOT derived: avoids Surelog CP0332
    // X1: for-with-inline-decl loop variable, read in a call argument
    static function int x1(int obj);
      x1 = obj;
      if (obj == 0) begin
        for (int i = 0; i < 2; i++) begin
          sinki(i);                // X1a: loop var, call arg, one `if` out
        end
        for (int j = 0; j < 2; j++)
          sinki(j);                // X1b: no begin/end around the body
      end
      for (int k = 0; k < 2; k++) begin
        sinki(k);                  // X1c: the same at depth 0 outside any if
      end
    endfunction
    // X2: foreach implicit index variable
    static function int x2(int obj);
      int a2[4];
      x2 = obj;
      if (obj == 0) begin
        foreach (a2[j]) begin
          sinki(j);                // X2a: foreach index, call arg
          sinki(a2[j]);            // X2b: foreach index under a select
        end
      end
    endfunction
    // X3: a for-BODY block local, read in the body
    static function int x3(int obj);
      x3 = obj;
      if (obj == 0) begin
        for (int m = 0; m < 2; m++) begin
          string b3s;
          b3s = "b";
          sink(b3s);               // X3a: for-body local, read in the body
          sinki(m);                // X3b: the loop var alongside it
        end
      end
    endfunction
    // X5's class twin: the same block-local shape, for alignment with X5
    static function int x5c(int obj);
      x5c = obj;
      if (obj == 0) begin
        string c5;
        c5 = "c";
        sink(c5);
      end
    endfunction
  endclass

  // X5: PACKAGE function -- curSubClassScope9 is false, must not move
  function automatic int x5(int obj);
    x5 = obj;
    if (obj == 0) begin
      string p5;
      p5 = "p";
      sink(p5);
      for (int i = 0; i < 2; i++)
        sinki(i);
    end
  endfunction
endpackage

// X4: MODULE scope -- function, task, initial, always_comb
module v2_loopvar;
  int q;
  int arr[4];
  pv2::shp sh;

  function automatic int mf(int obj);
    mf = obj;
    if (obj == 0) begin
      string m4;
      m4 = "m";
      pv2::sink(m4);              // X4a: module function, block local
      for (int i = 0; i < 2; i++)
        pv2::sinki(i);            // X4b: module function, loop var
    end
  endfunction

  task automatic mt(int obj);
    if (obj == 0) begin
      string t4;
      t4 = "t";
      pv2::sink(t4);              // X4c: module task, block local
    end
  endtask

  initial begin
    q = 0;
    sh = null;
    if (q == 0) begin
      string i4;
      i4 = "i";
      pv2::sink(i4);              // X4d: initial block, block local
      foreach (arr[j])
        pv2::sinki(j);            // X4e: initial block, foreach index
    end
  end

  always_comb begin
    if (q == 0) begin
      string a4;
      a4 = "a";
      pv2::sink(a4);              // X4f: always_comb, block local
    end
  end
endmodule
