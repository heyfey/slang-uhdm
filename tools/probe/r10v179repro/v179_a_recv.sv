// r10v179 ADVERSARIAL ARM A — RECEIVER SHAPES, written from scratch by the
// verifier (names/orders/numbers deliberately unlike r10uvm179's own arms, so
// an "everything is a/b/c" self-confirming grid cannot hide a distinguisher).
// MEASUREMENT ONLY; the official uhdm-cmp is the sole judge.
//
// Every cell puts the SAME kind of argument (a class TYPE-PARAMETER local,
// which the def-package listing emits as a `ref_var`) into the SAME window
// (an `if` CONDITION at control-body depth 0) and varies ONLY the receiver.
interface bus_if_z;
  logic clk;
  function automatic int peek_z(int q); return q; endfunction
endinterface

package pkg_zulu;

  class Widget;
    int tag;
  endclass

  class Depot;
    function int  probe(Widget w); return 0; endfunction
    function void stash(Widget w); endfunction
    task          drain(Widget w); endtask
  endclass

  class Middle;
    Depot leaf;
  endclass

  class Holder #(type ELEM = Widget);
    Depot        prop_depot;    // one class PROPERTY receiver
    Middle       mid;           // a.b chain receiver
    Depot        bank[4];       // indexed receiver
    Depot        assoc[string]; // associative-indexed receiver
    Depot        deck[$];       // queue-indexed receiver
    virtual bus_if_z vif;       // r10uvm176's face: a bare vif at depth 0
    int          flagz;

    extern function void r_prop();       // z01  prop_depot.probe(loc)
    extern function void r_local();      // z02  a body-LOCAL handle
    extern function void r_chain();      // z03  mid.leaf.probe(loc)
    extern function void r_index();      // z04  bank[2].probe(loc)
    extern function void r_assoc();      // z05  assoc["k"].probe(loc)
    extern function void r_queue();      // z06  deck[0].probe(loc)
    extern function void r_this();       // z07  this.prop_depot.probe(loc)
    extern function void r_none();       // z08  no receiver at all
    extern function void r_vif();        // z09  vif.peek_z(...) — MUST NOT MOVE
    extern function void r_vif_stmt();   // z10  vif.peek_z(...) statement twin
    extern function void r_prop_stmt();  // z11  STATEMENT twin of z01
    extern function void r_chain_stmt(); // z12  STATEMENT twin of z03
    extern function void r_index_stmt(); // z13  STATEMENT twin of z04
    extern task          r_prop_task();  // z14  the face inside a TASK body
    extern task          r_task_recv();  // z15  a TASK-kind callee, statement
  endclass

  function void Holder::r_prop();
    ELEM loc;
    if (prop_depot.probe(loc) == 0) flagz = 11;
  endfunction

  function void Holder::r_local();
    ELEM loc;
    Depot handy;
    if (handy.probe(loc) == 0) flagz = 12;
  endfunction

  function void Holder::r_chain();
    ELEM loc;
    if (mid.leaf.probe(loc) == 0) flagz = 13;
  endfunction

  function void Holder::r_index();
    ELEM loc;
    if (bank[2].probe(loc) == 0) flagz = 14;
  endfunction

  function void Holder::r_assoc();
    ELEM loc;
    if (assoc["k"].probe(loc) == 0) flagz = 15;
  endfunction

  function void Holder::r_queue();
    ELEM loc;
    if (deck[0].probe(loc) == 0) flagz = 16;
  endfunction

  function void Holder::r_this();
    ELEM loc;
    if (this.prop_depot.probe(loc) == 0) flagz = 17;
  endfunction

  function void Holder::r_none();
    ELEM loc;
    if (loose_probe(loc) == 0) flagz = 18;
  endfunction

  function void Holder::r_vif();
    int loc_i;
    if (vif.peek_z(loc_i) == 0) flagz = 19;
  endfunction

  function void Holder::r_vif_stmt();
    int loc_i;
    flagz = vif.peek_z(loc_i);
  endfunction

  function void Holder::r_prop_stmt();
    ELEM loc;
    prop_depot.stash(loc);
  endfunction

  function void Holder::r_chain_stmt();
    ELEM loc;
    mid.leaf.stash(loc);
  endfunction

  function void Holder::r_index_stmt();
    ELEM loc;
    bank[2].stash(loc);
  endfunction

  task Holder::r_prop_task();
    ELEM loc;
    if (prop_depot.probe(loc) == 0) flagz = 20;
  endtask

  task Holder::r_task_recv();
    ELEM loc;
    prop_depot.drain(loc);
  endtask

  function int loose_probe(Widget w); return 0; endfunction

endpackage

module tb_zulu;
  import pkg_zulu::*;
  Holder #(Widget) h_one;
  initial begin
    h_one = new();
  end
endmodule
