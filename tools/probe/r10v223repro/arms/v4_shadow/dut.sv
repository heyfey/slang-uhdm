// v4 — SHADOWING: the interface declares its own `sv4`, the same name the
// wildcard-imported package declares.  The local declaration wins for
// references; the question is what the NET LIST holds.
package pv4;
  int sv4 = 1;
  int other4 = 2;
endpackage

interface if_v4;
  import pv4::*;
  logic sv4;
  logic own_v4;
  assign own_v4 = sv4;
endinterface

module m_v4;
  import pv4::*;
  logic sv4;
  logic own_mv4;
  assign own_mv4 = sv4;
endmodule
