// v11u4 ADVERSARIAL v5 — the MINIMAL single-level-struct aggregate default,
// NO override anywhere.  Face (B) still fires (the def-view Rhs is an op75),
// and it replaces a port-view Rhs that already matched golden.
package r;
  typedef struct packed { int unsigned DAT; } bus_t;
  localparam bus_t BDEF = '{DAT: 32};
endpackage

interface tif #(parameter r::bus_t CFG = r::BDEF);
  logic d;
  modport mp (input d);
endinterface

module leaf (tif q); logic z; assign z = q.d; endmodule

module top;
  tif u();
  leaf a0 (.q(u));
endmodule
