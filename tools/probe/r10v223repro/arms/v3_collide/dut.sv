// v3 — NAME COLLISION: two packages each declaring `cv3`, both wildcard
// imported.  Neither name is referenced, so this is legal.
package pv3a;
  int cv3 = 1;
  int only_a3 = 2;
endpackage
package pv3b;
  int cv3 = 3;
  int only_b3 = 4;
endpackage

interface if_v3;
  import pv3a::*;
  import pv3b::*;
  logic own_v3;
endinterface

module m_v3;
  import pv3a::*;
  import pv3b::*;
  logic own_mv3;
endmodule
