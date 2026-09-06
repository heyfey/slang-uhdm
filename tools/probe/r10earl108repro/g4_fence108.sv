// r10earl108 g4 — THE FENCE ARM: every carrier and every formal this law must
// leave exactly where it found it, in ONE source, so the wide boundary and the
// grid both see them.
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole judge.
package s108;
  typedef struct packed {
    logic [1:0] a;
    logic [1:0] b;
    logic [1:0] c;
    logic       d;
  } rsp_t;
  parameter rsp_t RSP = '{a: 2'b01, b: 2'b01, c: 2'b10, d: 1'b0};
endpackage

// the LANDED struct-formal precedent (r10earl structOvPat) — must not move
module fs108 #(parameter s108::rsp_t R = '{default: 0}) (output logic [6:0] o);
  assign o = R;
endmodule
// a `logic` formal — Surelog COLLAPSES this one (CompileHelper.cpp:5303)
module fl108 #(parameter logic R = 0) (output logic o);
  assign o = R;
endmodule
// a `logic [6:0]` formal — same collapse, at the struct's own width
module fv108 #(parameter logic [6:0] R = 0) (output logic [6:0] o);
  assign o = R;
endmodule
// a `bit [6:0]` formal — substitutes, but reorderAssignmentPattern REVERSES
module fb108 #(parameter bit [6:0] R = 0) (output logic [6:0] o);
  assign o = R;
endmodule
// r10earl107's own carrier: the struct param arrives at a PORT high_conn
module fp108 (input s108::rsp_t p, output logic [6:0] o);
  assign o = p;
endmodule

module g4_fence108
  import s108::*;
(
  output logic [6:0] os,
  output logic       ol,
  output logic [6:0] ov,
  output logic [6:0] ob,
  output logic [6:0] op,
  output logic [6:0] oc,
  output logic [6:0] om
);
  // the module-body param_assign carrier (a module-local copy of the pattern)
  localparam rsp_t MB = RSP;
  // the cont_assign carrier (r10earl61's shape)
  assign oc = RSP;
  assign om = MB;

  fs108 #(.R(RSP)) i_s (.o(os));
  fl108 #(.R(RSP)) i_l (.o(ol));
  fv108 #(.R(RSP)) i_v (.o(ov));
  fb108 #(.R(RSP)) i_b (.o(ob));
  fp108            i_p (.p(RSP), .o(op));
endmodule
