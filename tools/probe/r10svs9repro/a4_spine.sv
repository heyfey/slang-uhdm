// r10svs9 arm a4 — THE LEFT SPINE: what the leftmost element of the parens-less
// path is allowed to be.  Clause (4) of the law says the spine must bottom out
// in a PLAIN IDENTIFIER; these cells execute that clause in both directions and
// pin what golden does with the spellings it refuses.
interface in_if(input bit clock);
  logic reset;
  logic sig;
  clocking cb @(posedge clock);
    input sig;
  endclocking
  modport IP(clocking cb, output reset, input clock);
endinterface

package pk;
  class Q;
    static int qs;
  endclass
endpackage

module sub(input bit clock);
  in_if u_in(clock);
endmodule

class B;
  virtual in_if.IP vif;
endclass

class C extends B;
  int r;

  // h1 the `this` KEYWORD as the leftmost element.
  task h1(); @ this.vif.clock; endtask

  // h2 the parenthesized twin of h1.
  task h2(); @(this.vif.clock); endtask

  // h3 the `super` KEYWORD as the leftmost element is a SYNTAX ERROR in
  //    Surelog's grammar ("no viable alternative at input '@ super'"), even
  //    though `this` and `$root` are both accepted there.  The cell is kept as
  //    a REFUTATION of the guess that the parens-less form takes any prefix.

  // h4 a plain identifier, THREE components deep (the Opentitan spelling
  //    `@cfg.clk_rst_vif.cb;`).
  task h4(); @ vif.cb.sig; endtask
endclass

module top;
  bit clk = 0;
  sub u_sub(clk);
  bit raw;

  // h5 a DEEP hierarchical path: instance, then the interface inside it, then
  //    a signal.  THREE components, leftmost a plain identifier.
  always @ u_sub.u_in.clock raw <= 1;
  // h6 the parenthesized twin of h5.
  always @(u_sub.u_in.clock) raw <= 1;

  // h7 `$root`-rooted, parens-LESS.
  always @ $root.top.raw raw <= 1;

  // h8 a PACKAGE-SCOPED class static (`::`) is likewise a SYNTAX ERROR in the
  //     parens-less form ("extraneous input '::'"), so a MIXED-separator spine
  //     is unreachable through this grammar rule.  Clause (3) still tests the
  //     separator, because the same predicate must stay correct if the caller
  //     ever hands it a spine built some other way.
endmodule
