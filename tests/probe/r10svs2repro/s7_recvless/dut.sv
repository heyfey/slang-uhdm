// r10svs2 ARM s7 — THE SECOND SITE, and the pass's NEW SVSwitch HEAD.
// A RECEIVER-LESS call written WITHOUT parentheses (`cal_fcs`, SVSwitch
// Packet.sv:65/:77/:91).  Golden makes it a scope-scoped `ref_obj`; we emit a
// `func_call` carrying `vpiFunction`.  Every spelling is paired with its
// parens-ful positive control so the control can never drift unobserved.
class rl;
  int n;

  function int zero();  return 3;      endfunction
  function int one(int a); return a;   endfunction
  task void_t();        n = 1;         endtask

  function int f();
    int r;
    r = zero;            // (1) WITNESS: receiver-less, NO parens, EXPRESSION ctx
    r = r + zero;        // (2) same, as a binary-op operand
    $display("%0d", zero);   // (3) same, as a $display argument (SVSwitch :65)
    r = zero();          // (4) POSITIVE CONTROL: identical call WITH empty parens
    r = one(4);          // (5) POSITIVE CONTROL: a call that HAS an argument
    return r;
  endfunction

  // (6)/(7) live in a TASK because slang refuses "cannot invoke a task from
  // within a function" -- a measurement in itself.
  task g();
    void_t;              // (6) receiver-less TASK, no parens, STATEMENT ctx
    void_t();            // (7) POSITIVE CONTROL: the same task WITH parens
  endtask
endclass

module top;
  rl o;
  initial begin
    o = new();
    $display("%0d", o.f());
  end
endmodule
