// r10earl62 GRID C — the WHOLE reach of § defBodyTypedefSiteShare62, measured
// on golden BEFORE any code.  Every row is a MODULE-LOCAL type declaration read
// from a module that has TWO specializations, in every carrier the head could
// have been about (the brief's grid), beside the four controls that would have
// made a NARROWER law right:
//   * a PACKAGE enum / PACKAGE struct  (one symbol for all specializations)
//   * an ANONYMOUS enum variable       (no typedef -> not in emitTypedefs)
//   * a GEN-SCOPE-local typedef        (a DesignComponent of its own)
//   * a SINGLE-specialization module   (def body == the only instance body)
// LHS is always golden.
package q62;
  typedef enum logic [1:0] { QA, QB, QC } q_op_e;
  typedef struct packed { logic [1:0] m; logic n; } q_t;
endpackage

module c62 #(parameter int W = 8) (
  input  logic          clk,
  input  logic [W-1:0]  din,
  output logic [W-1:0]  dout,
  output logic [7:0]    r
);
  import q62::*;
  // --- module-local declarations, NO variable of the enum type ---
  typedef enum logic [1:0] { CA_, CB_, CC_ } c_op_e;
  typedef struct packed { c_op_e op; logic err; logic [1:0] sz; } c_t;
  typedef struct packed { c_t inner; logic tag; } c_outer_t;

  c_t        v;
  c_outer_t  ov;
  c_t        varr [0:1];
  q_t        qv;
  enum logic [1:0] { AN0, AN1, AN2 } anv;   // ANONYMOUS enum VARIABLE (control)

  struct packed { logic a; logic b; logic c; logic d; logic e; logic f; } pk;
  logic [1:0] t0, t1, t2, t3, t4, t5, t6;

  // (a) plain cont_assign RHS
  assign t0 = (v.op == CB_) ? 2'b01 : 2'b10;
  // (b) op75 member value, DIRECT
  // (c) op75 member value, TERNARY CONDITION
  // (d) op75 member value, TERNARY ARM
  // (e) op75 member value, BINARY OPERAND
  // (f) op75 member value, CONCAT OPERAND
  assign pk = '{ a: (v.op == CB_),
                 b: ((v.op != CC_) ? 1'b1 : 1'b0),
                 c: ((clk) ? (v.op == CA_) : 1'b0),
                 d: (v.err & (v.op == CB_)),
                 e: (|{v.err, (v.op == CC_)}),
                 f: (qv.n & (anv == AN1)) };
  // (g) NESTED pattern member value
  assign ov = '{ inner: '{ op: CB_, err: 1'b0, sz: 2'b11 }, tag: 1'b1 };
  // (h) array element member select
  assign t1 = varr[1].sz;
  // (i) NESTED member select a.b.c
  assign t2 = ov.inner.sz;
  // (j) PACKAGE struct member select + PACKAGE enum ref (controls)
  assign t3 = qv.m & {2{(qv.m[0] == 1'b1)}};
  assign t4 = (q62::QB == q_op_e'(qv.m)) ? 2'b11 : 2'b00;
  // (k) ANONYMOUS enum ref (control)
  assign t5 = (anv == AN2) ? 2'b01 : 2'b00;
  // (l) procedural carrier
  always_comb begin
    t6 = (v.op == CC_) ? 2'b11 : ov.inner.sz;
  end
  // (m) GEN-SCOPE carriers: a gen-local typedef (control) beside a module-local read
  generate
    if (W > 4) begin : gb
      typedef enum logic [1:0] { GA, GB } g_op_e;
      g_op_e gvv;
      logic [1:0] gt;
      assign gt = (gvv == GB) ? 2'b01 : ((v.op == CB_) ? 2'b10 : 2'b00);
      assign r = { 6'b0, gt };
    end else begin : gb
      assign r = 8'b0;
    end
  endgenerate
  assign dout = { {(W-2){1'b0}}, (t0 ^ t1 ^ t2 ^ t3 ^ t4 ^ t5 ^ t6) };
endmodule

// CONTROL: exactly one instantiation -> def body IS the instance body.
module c62_one (input logic clk, output logic [1:0] z);
  typedef enum logic [1:0] { OA, OB, OC } o_op_e;
  typedef struct packed { o_op_e op; logic [1:0] sz; } o_t;
  o_t ov1;
  assign z = (ov1.op == OB) ? ov1.sz : 2'b00;
endmodule

module top62c (input logic clk, output logic [15:0] o);
  logic [7:0] d8, r8a, r8b; logic [15:0] d16; logic [1:0] z;
  c62 #(.W(8))  u_a (.clk(clk), .din(8'h0),  .dout(d8),  .r(r8a));
  c62 #(.W(16)) u_b (.clk(clk), .din(16'h0), .dout(d16), .r(r8b));
  c62_one       u_c (.clk(clk), .z(z));
  assign o = d16 ^ {6'b0, r8a, z};
endmodule
