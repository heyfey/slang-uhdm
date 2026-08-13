package rp; class baseb; endclass
  class regb #(type T = baseb, string TN = "<unknown>"); endclass endpackage
package pb; import rp::*;
  class ub extends baseb;
    function void fb();
      regb #(ub, "ub") lv1;
      lv1 = null;
    endfunction
  endclass
endpackage
module topb; import pb::*; ub vb; initial vb = null; endmodule
