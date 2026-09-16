// VERIFIER arm (r11v51) — ROAD E.  e2_ca_lhskind claims "one Rhs (CFG.n), five
// LHS kinds", but two of its five cells CHANGE THE RHS TOO (`CFG.n[0]` and
// `CFG.n[3:0]` are a bit-select and a part-select over the hier_path, not the
// hier_path).  This arm holds the Rhs at exactly `CFG.n` for every LHS kind,
// which is what "the LHS kind is not a gate" has to be measured against.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  localparam cfg_t LIT = '{n: 3, base: 64'h1000};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT)
           (output logic [31:0] o_full, output logic [31:0] o_bit,
            output logic [31:0] o_part, output logic [31:0] o_arr [2],
            output logic signed [31:0] o_sgn, output logic [7:0] o_narrow,
            output logic [63:0] o_wide);
  assign o_full      = CFG.n;   // plain named net
  assign o_bit[0]    = CFG.n;   // bit-select LHS, Rhs UNCHANGED
  assign o_part[3:0] = CFG.n;   // part-select LHS, Rhs UNCHANGED
  assign o_arr[0]    = CFG.n;   // unpacked-array element LHS
  assign o_sgn       = CFG.n;   // signed net LHS
  assign o_narrow    = CFG.n;   // narrower LHS than the member
  assign o_wide      = CFG.n;   // wider LHS than the member
endmodule
