// § clsMethodLocalForeignPkgSpec428
package rp; class baseb; endclass
  class regb #(type T = int); endclass endpackage
package pb; import rp::*;
  class ub;
    function void fb();
      regb #(byte) lv1;
    endfunction
  endclass
endpackage
module topb; pb::ub vb; endmodule
