// r11v55 VERIFIER arm — W2 (the nested read) CROSSED WITH MULTI-INSTANCE AND
// OVERRIDE.  The W2 walk descends one pattern per member level and needs
// EVERY level to be a pattern (or a reference that reaches one).  Cut the
// shapes where an intermediate level is NOT a literal pattern:
//   u_def  — nested default (control)
//   u_ovr  — the whole outer struct overridden with another package localparam
//   u_part — the outer pattern names its inner member with a REFERENCE to a
//            package localparam of the inner type (`sub: p::IN2`), so the
//            intermediate setter is a NamedValue, not a pattern
//   u_mix  — the outer pattern is written INLINE at the instantiation with a
//            nested inline pattern
package p;
  typedef struct packed { int unsigned n; logic [15:0] w; } inner_t;
  typedef struct packed { inner_t sub; int unsigned k; } outer_t;
  localparam inner_t IN1 = '{n: 5,  w: 16'h00AA};
  localparam inner_t IN2 = '{n: 17, w: 16'h00BB};
  localparam outer_t OUT1 = '{sub: '{n: 5, w: 16'h00AA}, k: 9};
  localparam outer_t OUT2 = '{sub: '{n: 31, w: 16'h00CC}, k: 13};
  localparam outer_t OUTR = '{sub: IN2, k: 77};
endpackage
module leaf #(parameter p::outer_t OC = p::OUT1)
            (output logic [31:0] o_n, output logic [31:0] o_w,
             output logic [31:0] o_k);
  assign o_n = OC.sub.n;
  assign o_w = OC.sub.w;
  assign o_k = OC.k;
endmodule
module dut (output logic [31:0] a_n, output logic [31:0] a_w, output logic [31:0] a_k,
            output logic [31:0] b_n, output logic [31:0] b_w, output logic [31:0] b_k,
            output logic [31:0] c_n, output logic [31:0] c_w, output logic [31:0] c_k,
            output logic [31:0] d_n, output logic [31:0] d_w, output logic [31:0] d_k);
  leaf                      u_def (.o_n(a_n), .o_w(a_w), .o_k(a_k));
  leaf #(.OC(p::OUT2))      u_ovr (.o_n(b_n), .o_w(b_w), .o_k(b_k));
  leaf #(.OC(p::OUTR))      u_part(.o_n(c_n), .o_w(c_w), .o_k(c_k));
  leaf #(.OC('{sub: '{n: 41, w: 16'h00DD}, k: 99})) u_mix (.o_n(d_n), .o_w(d_w), .o_k(d_k));
endmodule
