// r10earl54 GRID a3 — the two connection paths a1/a2 did not reach.
//
// The `hcPrefix` line § connReplFoldNested54 sits next to has a special case:
//   const std::string& hcPrefix =
//       (!bindPath.empty() && !currentTopPrefix.empty()) ? currentTopPrefix
//                                                        : parentPrefix;
// i.e. a BOUND instance's high-conn names are TOP-scoped.  This pass's arm uses
// `prefix` and not `hcPrefix`, so a bound instance is the one shape whose ts
// fullname could come out differently -- measured here rather than assumed.
// Also covered: a UDP/gate-form connection, whose actual Surelog BIT-BLASTS
// (NetlistElaboration's `bitBlast`, the paNet_lvalue branch), so a replication
// there is compiled by a different route entirely.
package pk3_54;
  parameter int M = 4;
endpackage

module sink3_54 (input [7:0] a, output [7:0] o);
  assign o = ~a;
endmodule

module dut3_54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] w;
  sink3_54 u_plain (.a({sel ? d[3:0] : {4{1'b0}}, 4'h1}), .o(w));
  assign q = w;
endmodule

// The BOUND instance's connection carries a nested replication.
module probe3_54 (input logic [7:0] pa, output logic [7:0] po);
  assign po = pa;
endmodule

module a3_earl54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  dut3_54 u_dut (.sel(sel), .d(d), .q(q));

  // GATE-FORM instantiation with a replication in the actual: Surelog reaches
  // this through the udp/gate path, which bit-blasts.
  wire [3:0] gout;
  buf u_bufs [3:0] (gout, {4{1'b1}});
endmodule

bind dut3_54 probe3_54 u_bound (.pa({sel ? d[3:0] : {4{1'b1}}, 4'h2}), .po());
