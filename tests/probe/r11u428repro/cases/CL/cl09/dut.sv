// § clsMethodLocalForeignPkgSpec428
package rp; class baseb; endclass
  class regb #(type T = int); endclass endpackage
package pb; import rp::*;
  class ub;
    function void fb();
      regb #(byte) lv1;
      lv1 = null;
    endfunction
  endclass
endpackage
module topb; import pb::*; ub vb; initial vb = null; endmodule
