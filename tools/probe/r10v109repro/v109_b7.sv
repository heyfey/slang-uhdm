// r10v109repro/v109_b7.sv - minimal: the `= new` LHS index is a class property,
// the array is a METHOD LOCAL.  MEASUREMENT ONLY.
package pkb7;
  class Cell7;
    int q;
    function new(int a = 0); q = a; endfunction
  endclass
  class Rig7;
    int idxKappa7;
    extern function void b7set();
  endclass
  function void Rig7::b7set();
    Cell7 slot7[4];
    slot7[idxKappa7] = new(1);
  endfunction
endpackage
import pkb7::*;
module topb7;
  Rig7 r7;
  initial begin r7 = new(); r7.b7set(); end
endmodule
