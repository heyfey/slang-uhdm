// r10svs9 arm a1 — THE PARENS MATRIX on an event control over a DOTTED path
// through a VIRTUAL INTERFACE, in a class task.  This is the witness's own
// shape (SVSwitch/Environemnt.sv:63 `repeat (4) @ input_intf.clock;`) plus its
// parenthesized twin (Environemnt.sv:121 `repeat(10000) @(input_intf.clock);`),
// which the SAME FILE contains and golden shapes DIFFERENTLY.
//
// The interface mirrors SVSwitch/interface.sv exactly in the part that matters:
// a clocking block named `cb` and a PLAIN input port `clock` exposed through the
// modport.  `.clock` in the witness is therefore a SIGNAL, not a clocking block.
interface in_if(input bit clock);
  logic       data_status;
  logic [7:0] data_in;
  logic       reset;
  logic       rdy;
  clocking cb @(posedge clock);
    default input #1 output #1;
    output data_status;
    output data_in;
    input  rdy;
  endclocking
  modport IP(clocking cb, output reset, input clock);
endinterface

class C;
  virtual in_if.IP vif;
  bit    loc;
  int    r;

  // c1 THE WITNESS: parens-LESS event control, dotted, under a repeat count.
  task c1(); repeat (4) @ vif.clock; endtask

  // c2 the SAME dotted path, PARENTHESIZED, under a repeat count.
  task c2(); repeat (4) @(vif.clock); endtask

  // c3 parens-LESS, dotted, as a PLAIN event statement (no repeat).
  task c3(); @ vif.clock; endtask

  // c4 parenthesized, plain event statement.
  task c4(); @(vif.clock); endtask

  // c5 parens-LESS over the CLOCKING BLOCK itself (r10svs5's boundary object).
  task c5(); @ vif.cb; endtask

  // c6 parenthesized over the clocking block.
  task c6(); @(vif.cb); endtask

  // c7 EDGE: only spellable with parentheses.  NEGATIVE CONTROL for the law.
  task c7(); @(posedge vif.clock); endtask

  // c8 parens-LESS, NOT dotted.  NEGATIVE CONTROL: nothing to collapse.
  task c8(); @ loc; endtask

  // c9 THE SAME dotted read NOT under `@` — an assignment rhs.  The law must
  //    NOT touch this.
  task c9(); r = vif.clock; endtask

  // c10 the same dotted read as a CALL ARGUMENT.  Must not be touched.
  task c10(); $display("%b", vif.clock); endtask

  // c11 the same dotted read as an `if` CONDITION.  Must not be touched.
  task c11(); if (vif.clock) r = 1; endtask

  // c12 parens-LESS over a THREE-component path through the clocking block
  //     (r10svs5 § vifClockingPathComponent5 recovers `cb`; this cell is where
  //     the two laws meet).
  task c12(); @ vif.cb.rdy; endtask

  // c13 parenthesized three-component twin of c12.
  task c13(); @(vif.cb.rdy); endtask
endclass

module top;
  bit clk = 0;
  in_if u_if(clk);
  C c;
  initial begin
    c = new();
    c.vif = u_if;
  end
endmodule
