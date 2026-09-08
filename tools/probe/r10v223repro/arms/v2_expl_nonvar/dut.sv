// v2 — EXPLICIT import of NON-DATA names into an interface: a typedef, a
// parameter, a class, a function.  None may mint a net.  A second interface
// explicitly imports the one real VARIABLE, which must mint exactly one.
package pv2;
  typedef logic [7:0] byte_t;
  parameter int PV2 = 3;
  class cv2; int m; endclass
  function automatic int fv2(); return 1; endfunction
  int dv2 = 5;
  string sv2 = "s";
endpackage

interface if_v2a;
  import pv2::byte_t;
  import pv2::PV2;
  import pv2::cv2;
  import pv2::fv2;
  logic own_v2a;
endinterface

interface if_v2b;
  import pv2::dv2;
  logic own_v2b;
endinterface
