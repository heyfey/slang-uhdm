// r10v109repro/v109_b6.sv - THE MINIMAL REGRESSION ARM.  A class property used
// as the INDEX of the LHS of a `= new`.  MEASUREMENT ONLY.
package pkb6;
  class Cell6;
    int q;
    function new(int a = 0); q = a; endfunction
  endclass
  class Rig6;
    Cell6 slot6[4];
    int   idxKappa6;
    extern function void b6set();
  endclass
  function void Rig6::b6set();
    slot6[idxKappa6] = new(1);
  endfunction
endpackage
import pkb6::*;
module topb6;
  Rig6 r6;
  initial begin r6 = new(); r6.b6set(); end
endmodule
