// r10svs2 VERIFIER ARM w1 — THE GAP THE IMPLEMENTER'S ARM SET CANNOT SEE.
// § parensLessFuncRefIsRefObj is gated on `realIsFunc18 && rawText==sub.name`
// with NO STATEMENT-POSITION GATE, yet the law as stated is scoped to
// "EXPRESSION (not statement) position".  Arm s7 measured a parens-less TASK in
// statement position (kept out by realIsFunc18) and a parens-less FUNCTION in
// EXPRESSION position (the law).  THE MISSING CELL is a parens-less FUNCTION in
// STATEMENT POSITION -- legal SystemVerilog (the return value is discarded), and
// the one cell where the gate has no guard at all.
class sf;
  int n;
  function int zero(); n = n + 1; return 3; endfunction
  task     void_t();   n = 2;               endtask

  task g();
    zero;        // (1) THE WITNESS: FUNCTION, receiver-less, NO parens, STATEMENT
    zero();      // (2) POSITIVE CONTROL: same function, STATEMENT, WITH parens
    void_t;      // (3) TASK, no parens, STATEMENT (s7 cell, re-measured here)
    void_t();    // (4) TASK, parens, STATEMENT
  endtask

  function int f();
    int r;
    r = zero;    // (5) FUNCTION, no parens, EXPRESSION -- the law's own cell
    r = r + zero();  // (6) POSITIVE CONTROL
    return r;
  endfunction
endclass

module top;
  sf o;
  initial begin
    o = new();
    o.g();
    $display("%0d", o.f());
  end
endmodule
