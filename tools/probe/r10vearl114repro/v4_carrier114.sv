// r10vearl114 ARM v4 -- THE CARRIER AXIS and the PACKAGE / PARAMETER roots
// (the two `getObject` branches the law does NOT model: `port` and
// `param_assign`).  MEASUREMENT ONLY.
`include "pv114.sv"
package pk114;
  import pv114::*;
  vs_t          pkvar;
  parameter vs_t PKP = '{v:1'b1, op:VE2, d:8'h5A};
endpackage

module v4_carrier114 #(parameter pv114::vs_t MP = '{v:1'b1, op:pv114::VE1, d:8'h3C})
                      (output logic o);
  import pv114::*;
  vs_t m_arr [2];
  vn_t m_nest;

  for (genvar i = 0; i < 2; i++) begin : g
    // k1: KEYED pattern (the law's own carrier)
    vs_t k1; assign k1 = '{v: m_arr[i].v, op: m_arr[i].op, d: m_arr[i].d};
    // k2: POSITIONAL pattern
    vs_t k2; assign k2 = '{m_arr[i].v, m_arr[i].op, m_arr[i].d};
    // k3: pattern NESTED in a pattern
    vn_t k3; assign k3 = '{inner: '{v: m_arr[i].v, op: m_arr[i].op, d: m_arr[i].d}, tag: 4'h3};
    // k4: PLAIN Rhs, no pattern
    logic k4; assign k4 = m_arr[i].v;
    // k5: a BINARY OPERATION operand
    logic k5; assign k5 = m_arr[i].v & m_arr[i].d[0];
    // k6: pattern in an ALWAYS_COMB
    vs_t k6; always_comb k6 = '{v: m_arr[i].v, op: m_arr[i].op, d: m_arr[i].d};
    // k7: MODULE-PARAMETER root  (getObject's param_assign branch)
    vs_t k7; assign k7 = '{v: MP.v, op: MP.op, d: MP.d};
    // k8: PACKAGE-parameter root
    vs_t k8; assign k8 = '{v: pk114::PKP.v, op: pk114::PKP.op, d: pk114::PKP.d};
    // k9: PACKAGE-variable root
    vs_t k9; assign k9 = '{v: pk114::pkvar.v, op: pk114::pkvar.op, d: pk114::pkvar.d};
    // k10: a nested-struct root read three components deep
    vs_t k10; assign k10 = '{v: m_nest.inner.v, op: m_nest.inner.op, d: m_nest.inner.d};
  end
  assign o = 1'b0;
endmodule
