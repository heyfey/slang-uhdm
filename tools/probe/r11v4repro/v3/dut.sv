// v11u4 ADVERSARIAL v3 — SHARING and MULTI-VIEW: several port views of the SAME
// interface def in the SAME module (does face (C)'s in-place
// `Typespec(nullptr)` corrupt a neighbour that must KEEP its typespec?), an
// interface ARRAY element reached by a NAMED MODPORT connection, and an array
// of receiving module instances.
package r;
  typedef struct packed { int unsigned DAT; } bus_t;
  localparam bus_t BDEF = '{DAT: 32};
  localparam bus_t BOVR = '{DAT: 64};
endpackage

interface tif #(parameter int PI = 3,
                parameter int NI = -3,          // OPERATION default
                parameter r::bus_t CFG = r::BDEF);
  localparam int BYT = PI * 2;                  // OPERATION default
  logic [PI-1:0] d;
  modport mp (input d);
endinterface

module leaf  (tif q);    logic z; assign z = q.d[0]; endmodule
module leafm (tif.mp q); logic z; assign z = q.d[0]; endmodule

module top;
  tif #(.PI(9), .NI(-9), .CFG(r::BOVR)) u_ov();
  tif arr [1:0] ();
  // Two views that MUST diverge: a2 is the named-modport cell (keeps the
  // connected values AND its typespec), a0/a1 fold at the default.
  leaf  a0 (.q(u_ov));
  leaf  a1 (u_ov);
  leafm a2 (.q(u_ov.mp));
  // ARRAY-ELEMENT views, plain and named MODPORT.
  leaf  a3 (.q(arr[0]));
  leafm a4 (.q(arr[1].mp));
  // An ARRAY of receiving module instances, all bound to the same interface.
  leaf  a5 [1:0] (.q(u_ov));
endmodule
