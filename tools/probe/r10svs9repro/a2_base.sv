// r10svs9 arm a2 — THE BASE: is the parens-less collapse a VIRTUAL-INTERFACE
// law, or a law about the parens-less event-control FORM itself?
//
// Every cell here is a parens-LESS `@ <dotted path>` over a base that is NOT a
// virtual interface, paired with its parenthesized twin.  If golden collapses
// these too, the law is about the FORM and the predicate must not mention
// virtual interfaces; if it declines, the predicate is scoped to the vif base.
interface in_if(input bit clock);
  logic       reset;
  logic       rdy;
  clocking cb @(posedge clock);
    input rdy;
  endclocking
  modport IP(clocking cb, output reset, input clock);
endinterface

module sub(input bit clock);
  logic sig;
endmodule

package pk;
  bit pev;
endpackage

class Ev;
  event  e;
  bit    b;
endclass

module top;
  bit clk = 0;
  bit raw;
  in_if u_if(clk);            // a REAL interface INSTANCE
  sub   u_sub(clk);           // a module instance, for a hierarchical name
  struct packed { bit f; bit g; } st;
  bit   arr [0:3];
  Ev    ev = new();

  // d1 real interface INSTANCE, parens-LESS
  always @ u_if.clock raw <= 1;
  // d2 real interface INSTANCE, PARENTHESIZED twin
  always @(u_if.clock) raw <= 1;

  // d3 real interface instance, member = the CLOCKING BLOCK, parens-LESS
  always @ u_if.cb raw <= 1;
  // d4 parenthesized twin
  always @(u_if.cb) raw <= 1;

  // d5 HIERARCHICAL module reference, parens-LESS
  always @ u_sub.sig raw <= 1;
  // d6 parenthesized twin
  always @(u_sub.sig) raw <= 1;

  // d7 a packed STRUCT member, parens-LESS
  always @ st.f raw <= 1;
  // d8 parenthesized twin
  always @(st.f) raw <= 1;

  // d9 a CLASS-object member (an event), parens-LESS
  always @ ev.e raw <= 1;
  // d10 parenthesized twin
  always @(ev.e) raw <= 1;

  // d11 a PACKAGE-SCOPED name — `::`, not `.`.  Control for "dotted".
  always @ pk::pev raw <= 1;
  // d12 parenthesized twin
  always @(pk::pev) raw <= 1;

  // d13 an INDEX SELECT with no dot: parens-LESS is a SYNTAX ERROR in
  //     Surelog (`@ hierarchical_identifier` admits no select), REFUTING the
  //     idea that the parens-less form accepts arbitrary expressions.  Only the
  //     parenthesized spelling exists, and it is the control.
  always @(arr[1]) raw <= 1;
endmodule
