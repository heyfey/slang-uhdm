// r10svs5 VERIFIER ARM v2 — NAME SPELLING, which the law's clause (4) reads
// character by character.  The standing brief requires: "check ESCAPED
// identifiers and macro-written spellings if any gate reads names".  The shipped
// a5 arm checks spaces, a comment, a newline and a whole-path macro; it never
// checks an ESCAPED identifier anywhere, nor a macro that supplies only PART of
// the path, nor a component whose name is a PREFIX/SUFFIX of neighbouring text.
`define LEAF ds
`define COMP cb
`define VIA(H) H.cb.din

interface iface_v2(input bit clock);
  logic ds;
  logic [7:0] din;
  logic cbx;
  logic \esc$ds ;

  // an ESCAPED clocking-block name whose stripped name is `cb2`
  clocking \cb2 @(posedge clock);
    default input #1 output #1;
    output ds;
    output din;
  endclocking

  clocking cb@(posedge clock);
    default input #1 output #1;
    output ds;
    output din;
    output \esc$ds ;   // an ESCAPED clocking-item name
  endclocking

  modport IP(clocking cb, clocking \cb2 , input clock);
endinterface

class drv_v2;
  virtual iface_v2.IP vif;

  task go();
    // v2a CONTROL, tight, plain
    vif.cb.ds <= 1;
    // v2b an ESCAPED CLOCKING-BLOCK name in the path
    vif.\cb2 .ds <= 1;
    // v2c an ESCAPED LEAF (clocking item) name
    vif.cb.\esc$ds <= 1;
    // v2d the LEAF supplied by a macro
    vif.cb.`LEAF <= 1;
    // v2e the COMPONENT supplied by a macro
    vif.`COMP .ds <= 1;
    // v2f the handle passed INTO a macro that spells the rest of the path
    `VIA(vif) <= 8'h1;
  endtask
endclass

module top_v2;
  bit clock = 0;
  iface_v2 i_v(clock);
  drv_v2 d;
  initial begin
    d = new();
    d.vif = i_v;
    d.go();
  end
endmodule
