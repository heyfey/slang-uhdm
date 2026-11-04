// § importCloneSharesHomeReturn218 — c12_inbody_ctl: control: an in-body method (not cloned into the importer)
package p1;
  class c;
    function int f();
      return 1;
    endfunction
  endclass
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
