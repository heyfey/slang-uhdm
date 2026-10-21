// § clsMethodLocalForeignPkgSpec428
package rp; class baseb; endclass
  class regb #(type T = baseb); endclass endpackage
import rp::*;
class ub;
  function void fb();
    regb #(byte) lv1;
    lv1 = null;
  endfunction
endclass
module topb; ub vb; initial vb = null; endmodule
