// r10uvm173 arm A — THE WRITTEN QUALIFIER, one package, six call sites.
// The law under test: a call emitted inside the package's DEF listing binds
// THAT listing's twin of the callee; only the package-qualified spelling is
// re-pointed at the elaborated twin.  Names are deliberately UNRELATED to each
// other and to the arm letter (an a_t/b_t/c_t grid is self-confirming).
package quill_pkg;

  function automatic int unsigned tally(int unsigned seed);
    int unsigned acc;
    acc = seed;
    for (int unsigned k = 0; k < 3; k++)
      acc = acc + k;
    return acc;
  endfunction

  function automatic int unsigned bareCaller(int unsigned n);
    // UNQUALIFIED — golden keeps the def listing's own twin.
    return tally(n) + 1;
  endfunction

  function automatic int unsigned qualCaller(int unsigned n);
    // PACKAGE-QUALIFIED — golden re-points at the elaborated twin.
    return quill_pkg::tally(n) + 2;
  endfunction

  function automatic int unsigned mixedCaller(int unsigned n);
    // Both spellings in ONE expression, so the two answers must differ inside
    // a single statement or the arm is not testing the discriminator.
    return tally(n) + quill_pkg::tally(n);
  endfunction

  task automatic soakTask(input int unsigned n, output int unsigned o);
    o = tally(n);
  endtask

  task automatic soakQualTask(input int unsigned n, output int unsigned o);
    o = quill_pkg::tally(n);
  endtask

  class Ledger;
    int unsigned held;
    function new();
      held = 0;
    endfunction
    // A CLASS METHOD inside the package, both spellings.
    function int unsigned viaMethod(int unsigned n);
      return tally(n) + quill_pkg::tally(n);
    endfunction
  endclass

endpackage

module quill_top (input logic clk, output int unsigned q1, output int unsigned q2);
  import quill_pkg::*;
  int unsigned r1, r2;
  Ledger led;
  initial begin
    led = new();
    soakTask(4, r1);
    soakQualTask(5, r2);
  end
  // Module-scope calls: these are emitted after the package views and must
  // keep binding the elaborated twin in every arm.
  assign q1 = bareCaller(7) + quill_pkg::tally(8);
  assign q2 = mixedCaller(9) + r1 + r2;
endmodule
