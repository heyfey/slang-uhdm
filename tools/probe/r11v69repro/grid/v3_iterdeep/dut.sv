// v11u69 v3 — MULTI-ITERATION WITH THE LAW ACTUALLY FIRING.  The brief names
// "generate-for with multiple iterations (per-iteration clones, per-iteration
// values)" as its own cell; the implementer's `g2_iter` writes `o[k] = CFG.n`,
// an unpacked-array-ELEMENT Lhs, so `plainLhs=0` and the law never runs there.
// Here every Lhs is a WHOLE NAME that is gen-local WITH A MODULE-BODY NAMESAKE,
// which is exactly the `genLocal=0` cell `g10_lhsbind`'s `gname` measured — so
// the law fires once per iteration.
package p;
  typedef struct packed { int unsigned n; int unsigned m; } inner_t;
  typedef struct packed { inner_t sub; logic [7:0] w; } outer_t;
  localparam outer_t OLIT = '{sub: '{n: 11, m: 22}, w: 8'h5A};
  typedef struct packed { int unsigned n; int unsigned m; } cfg_t;
  localparam cfg_t LIT = '{n: 7, m: 9};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT,
             parameter p::outer_t OC = p::OLIT)
  (input  logic a_i,
   output logic [31:0] o_s0, o_s1, o_s2,
   output logic [31:0] o_v0, o_v1,
   output logic [31:0] o_two,
   output logic [31:0] o_d0, o_d1);

  logic [31:0] sv;   // the MODULE-BODY namesakes
  logic [31:0] vv;
  logic [31:0] dv;

  // THREE iterations, the SAME source literal: per-iteration clone?
  logic [31:0] st [0:2];
  for (genvar k = 0; k < 3; k++) begin : gs
    logic [31:0] sv;
    assign sv = CFG.n;
    assign st[k] = sv;
  end
  assign o_s0 = st[0];
  assign o_s1 = st[1];
  assign o_s2 = st[2];

  // TWO iterations, PER-ITERATION VALUE picked by the genvar.
  logic [31:0] vt [0:1];
  for (genvar k = 0; k < 2; k++) begin : gv
    logic [31:0] vv;
    if (k == 0) begin : a0
      assign vv = CFG.n;
    end else begin : a1
      assign vv = CFG.m;
    end
    assign vt[k] = vv;
  end
  assign o_v0 = vt[0];
  assign o_v1 = vt[1];

  // TWO-level read (W2) inside a generate block, whole-name namesake Lhs.
  logic [31:0] tw;
  if (1) begin : gt
    logic [31:0] tw;
    assign tw = OC.sub.n;
    assign o_two = tw;
  end

  // NESTED gen-for inside gen-for, the law firing in every leaf.
  logic [31:0] dt [0:1];
  for (genvar a = 0; a < 1; a++) begin : go
    for (genvar b = 0; b < 2; b++) begin : gin
      logic [31:0] dv;
      assign dv = CFG.n;
      assign dt[b] = dv;
    end
  end
  assign o_d0 = dt[0];
  assign o_d1 = dt[1];

  assign sv = 32'd0;
  assign vv = 32'd0;
  assign dv = 32'd0;
  assign tw = 32'd0;
endmodule
