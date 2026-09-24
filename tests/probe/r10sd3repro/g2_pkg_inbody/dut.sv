// g2 — package class with an IN-BODY method (UVM's
// `uvm_tlm_generic_payload::do_compare` shape, the ONE golden-NULL key in the
// SeqDriver census).  Golden leaves the method's typespecs UNINSTANCED.
package p2;
  class c2;
    function bit f2(string kind);
      string loc;
      loc = kind;
      f2 = (loc == "HARD");
    endfunction
  endclass
endpackage
module top2;
  import p2::*;
  c2 h;
  initial h = new();
endmodule
