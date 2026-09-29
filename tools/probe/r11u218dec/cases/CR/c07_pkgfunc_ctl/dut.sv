// § importCloneSharesHomeReturn218 — c07_pkgfunc_ctl: control: a package-level function (shared in ours already)
package p1;
  function int g();
    return 1;
  endfunction
  class c;
  endclass
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
