// r10v110 arm v5 — HIERARCHICAL and VIRTUAL-INTERFACE receivers (R-hier110's
// half).  Kept in its OWN arm: the pinned golden Surelog rejects a `virtual`
// interface signal type, so this arm is measured for a REGRESSION only.
package Vk5;
  class Cv5;
    int  d5[];
    int  f5;
  endclass
endpackage
interface if5;
  byte IB5[];
  int  IS5;
endinterface
module inner5;
  import Vk5::*;
  Cv5 ih5;
  int iw5[];
  initial begin ih5 = new(); ih5.d5 = new [2]; iw5 = new [3]; end
endmodule
module port5(if5 PP5);
  initial begin
    PP5.IB5 = new [4];      // v5f01 INTERFACE PORT member (hierarchical) (fenced)
    PP5.IS5 = 4;            // v5f02 control
  end
endmodule
module v5top;
  if5 W5();
  inner5 D5();
  port5 U5(.PP5(W5));
  int hv5[];
  initial begin
    hv5      = new [5];     // v5f03 undotted local            (control)
    D5.iw5   = new [6];     // v5f04 CROSS-INSTANCE array      (hier, undotted member)
    D5.ih5.d5 = new [7];    // v5f05 CROSS-INSTANCE dotted     (fenced)
    W5.IB5   = new [8];     // v5f06 named-instance iface member (hier)
  end
endmodule
