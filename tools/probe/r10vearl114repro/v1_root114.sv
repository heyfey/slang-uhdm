// r10vearl114 ARM v1 -- THE ROOT-KIND AXIS, written independently of the
// implementer's t1.  Every row is a gen-for depth-1 KEYED pattern in a
// continuous assign whose target is a gen-local packed struct carrying an
// ENUM member; only the path's ROOT changes.  MEASUREMENT ONLY.
`include "pv114.sv"
module v1_root114 (
    input  pv114::vs_t x5_port,          // r5: a PORT of struct type
    input  pv114::vs_t x10_parr [2],     // r10: a PORT unpacked array
    output logic o);
  import pv114::*;
  vs_t  x1_marr [2];                     // r1: module-body unpacked array VAR
  vs_t  x2_msingle;                      // r2: module-body plain struct
  wire  vs_t x3_wsingle;                 // r3: WIRE-declared struct
  wire  vs_t x4_warr [2];                // r4: WIRE-declared unpacked array
  localparam vs_t x6_lp = '{v:1'b1, op:VE1, d:8'hAB};   // r6: a LOCALPARAM
  struct packed { logic a; ve_t b; logic [7:0] c; } x7_anon;  // r7: ANON type
  vn_t  x8_nest;                         // r8: NESTED struct
  vs_t  x9_2d [2][2];                    // r9: 2-D unpacked array

  assign x3_wsingle = '{v:1'b0, op:VE0, d:8'h00};
  assign x4_warr[0] = '{v:1'b0, op:VE0, d:8'h00};
  assign x4_warr[1] = '{v:1'b0, op:VE0, d:8'h00};

  for (genvar i = 0; i < 2; i++) begin : g
    vs_t t1; assign t1 = '{v: x1_marr[i].v,   op: x1_marr[i].op,   d: x1_marr[i].d};
    vs_t t2; assign t2 = '{v: x2_msingle.v,   op: x2_msingle.op,   d: x2_msingle.d};
    vs_t t3; assign t3 = '{v: x3_wsingle.v,   op: x3_wsingle.op,   d: x3_wsingle.d};
    vs_t t4; assign t4 = '{v: x4_warr[i].v,   op: x4_warr[i].op,   d: x4_warr[i].d};
    vs_t t5; assign t5 = '{v: x5_port.v,      op: x5_port.op,      d: x5_port.d};
    vs_t t6; assign t6 = '{v: x6_lp.v,        op: x6_lp.op,        d: x6_lp.d};
    vs_t t7; assign t7 = '{v: x7_anon.a,      op: x7_anon.b,       d: x7_anon.c};
    vs_t t8; assign t8 = '{v: x8_nest.inner.v, op: x8_nest.inner.op, d: x8_nest.inner.d};
    vs_t t9; assign t9 = '{v: x9_2d[i][0].v,  op: x9_2d[i][0].op,  d: x9_2d[i][0].d};
    vs_t t10; assign t10 = '{v: x10_parr[i].v, op: x10_parr[i].op, d: x10_parr[i].d};
  end
  assign o = 1'b0;
endmodule
