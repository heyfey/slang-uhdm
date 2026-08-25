// A CLASS PROPERTY with the same name as the imported parameter (the actual is
// a variable, which the re-point must never touch).
package pv31;
  parameter int FIELD = 31;
endpackage
package pv31b;
  class c31;
    int FIELD;
    function int m(); return FIELD; endfunction
  endclass
endpackage
import pv31::*;
module top_v31;
  int z;
  initial z = FIELD;
endmodule
