// r10uvm195 arm E — THE HEAD, minimised.  This 20-line file reproduces the
// SeqDriver x2 / MiniAmiq x2 corpus head EXACTLY: 29 cmp lines, one `^LHS:`,
// `LHS: <null>` above OUR `ref_var` for the `process`-typed subroutine-level
// local, on the pristine binary — and CMP_EQUAL on the patched one.  It is the
// POSITIVE CONTROL for the whole pass.
package quarry195;
  class Chisel195;
    extern task sluice195(string weir195="");
  endclass
  task Chisel195::sluice195(string weir195="");
    int gantry195 = 3;
    process forge195;
    string tongs195;
    tongs195 = "x";
  endtask
endpackage
package loom195;
  import quarry195::*;
  class Bobbin195;
    function void anvil195();
      Chisel195 hammer195;
      hammer195 = null;
    endfunction
  endclass
endpackage
