// v19 — an UNINSTANTIATED interface and an UNINSTANTIATED module, both
// wildcard-importing and USING the imported name.  Does the hoisted def net
// become the reference's vpiActual, and does golden do that?
package pv19;
  logic [3:0] lv19;
endpackage

interface if_v19;
  import pv19::*;
  logic [3:0] own_v19;
  assign own_v19 = lv19;
endinterface

module m_v19;
  import pv19::*;
  logic [3:0] own_mv19;
  assign own_mv19 = lv19;
endmodule
