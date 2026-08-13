// g7 — one package class carrying BOTH an out-of-body method and an in-body
// one.  The in-body method is the shape UVM's
// `uvm_tlm_generic_payload::do_compare` has (the ONE golden-NULL key in the
// SeqDriver census); the oob method is the shape the other 30 keys have.  Both
// live in ONE class so the cell shows the discriminator is OUT-OF-BODY-NESS
// and not the class, the package or the view.
package p7;
  class c7;
    extern function bit f7o(string kind);
    function bit f7i(string kind);
      string loc;
      loc = kind;
      f7i = (loc == "HARD");
    endfunction
  endclass
  function bit c7::f7o(string kind);
    string loc;
    loc = kind;
    f7o = (loc == "HARD");
  endfunction
endpackage
module top7;
  import p7::*;
  c7 h;
  initial h = new();
endmodule
