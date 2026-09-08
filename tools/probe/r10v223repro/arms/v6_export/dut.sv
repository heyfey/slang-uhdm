// v6 — RE-EXPORT: pv6mid imports pv6base and EXPORTS it; the interface
// imports only pv6mid.
package pv6base;
  int bv6 = 1;
  string bs6 = "b";
endpackage
package pv6mid;
  import pv6base::*;
  export pv6base::*;
  int mv6 = 2;
endpackage

interface if_v6;
  import pv6mid::*;
  logic own_v6;
endinterface

module m_v6;
  import pv6mid::*;
  logic own_mv6;
endmodule
