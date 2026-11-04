// v14 — a DIAMOND package graph imported by an interface: pd0 <- pd1, pd2,
// both <- pd3, interface imports pd3 AND pd1 directly.  Surelog does not
// de-duplicate.
package pd0_14;
  int d0v = 1;
endpackage
package pd1_14;
  import pd0_14::*;
  int d1v = 2;
endpackage
package pd2_14;
  import pd0_14::*;
  int d2v = 3;
endpackage
package pd3_14;
  import pd1_14::*;
  import pd2_14::*;
  int d3v = 4;
endpackage

interface if_v14;
  import pd3_14::*;
  import pd1_14::*;
  logic own_v14;
endinterface

module m_v14;
  import pd3_14::*;
  import pd1_14::*;
  logic own_mv14;
endmodule
