// r10uvm203 grid arm D — the `$dumpvars` SCOPE NAME against the materialized
// net listing.  `gd203` is BOTH the module's own name (so slang resolves the
// argument as a scope) and the name of a hoisted out-of-body constructor
// local, which is the SimpleUVM shape exactly (module `top`, hoisted
// `uvm_component::new`'s `uvm_root top`).  `ge203x` is the CONTROL: a scope
// name that no net listing carries, so its implicit wire must still be minted.
package pd203;
  class Cd203;
    extern function new();
  endclass
  function Cd203::new();
    Cd203 gd203;                         // hoisted -> a net named `gd203`
    gd203 = null;
  endfunction
endpackage

import pd203::*;

module gd203x;
  bit clk;
endmodule

module gd203;
  bit clk;
  gd203x sub();
  initial begin
    $dumpvars(0, gd203);                 // COLLIDES with the hoisted net
  end
  initial begin
    $dumpvars(0, sub);                   // the CONTROL: no such net
  end
endmodule
