// r10v109repro/v109_b8.sv - the CONTROL for v109_b7: the same array local and
// the same class-property index on an ORDINARY (non-`new`) LHS.
package pkb8;
  class Cell8;
    int q;
    function new(int a = 0); q = a; endfunction
  endclass
  class Rig8;
    int idxKappa8;
    extern function void b8set();
  endclass
  function void Rig8::b8set();
    Cell8 slot8[4];
    slot8[idxKappa8] = null;
  endfunction
endpackage
import pkb8::*;
module topb8;
  Rig8 r8;
  initial begin r8 = new(); r8.b8set(); end
endmodule
