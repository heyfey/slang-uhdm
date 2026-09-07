// r10vearl114 ARM v3 -- THE INTERFACE AXIS: an interface INSTANCE root, an
// interface ARRAY root, a MODPORT PORT root inside a child, and a generate
// scope INSIDE an interface.  MEASUREMENT ONLY.
`include "pv114.sv"
interface iv114;
  pv114::vs_t sig;
  pv114::vs_t sarr [2];
  modport mp (input sig, input sarr);
  for (genvar k = 0; k < 2; k++) begin : gi   // a gen scope INSIDE an interface
    pv114::vs_t it; assign it = '{v: sig.v, op: sig.op, d: sig.d};
    pv114::vs_t ia; assign ia = '{v: sarr[k].v, op: sarr[k].op, d: sarr[k].d};
  end
endinterface

module v3child114 (iv114.mp bus, output logic co);
  import pv114::*;
  for (genvar i = 0; i < 1; i++) begin : g
    vs_t p1; assign p1 = '{v: bus.sig.v,     op: bus.sig.op,     d: bus.sig.d};
    vs_t p2; assign p2 = '{v: bus.sarr[i].v, op: bus.sarr[i].op, d: bus.sarr[i].d};
  end
  assign co = 1'b0;
endmodule

module v3_iface114 (output logic o);
  import pv114::*;
  iv114 u_if();
  iv114 u_ifa [2] ();
  v3child114 u_c (.bus(u_if), .co());
  for (genvar i = 0; i < 2; i++) begin : g
    vs_t q1; assign q1 = '{v: u_if.sarr[i].v, op: u_if.sarr[i].op, d: u_if.sarr[i].d};
    vs_t q2; assign q2 = '{v: u_ifa[i].sig.v, op: u_ifa[i].sig.op, d: u_ifa[i].sig.d};
    vs_t q3; assign q3 = '{v: u_if.sig.v,     op: u_if.sig.op,     d: u_if.sig.d};
  end
  assign o = 1'b0;
endmodule
