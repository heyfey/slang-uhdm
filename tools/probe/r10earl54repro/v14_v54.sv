// v54 VERIFIER ARM v14 — CO-OCCURRENCE WITH § connPathRootTs53.
// foldConnReplNested54 runs on the SAME `h` immediately AFTER
// bindConnPathRootTs53, which rewrites typespecs on every hier_path inside the
// actual.  An actual holding BOTH a hier_path (struct / interface member) and a
// nested replication is the only shape where the two arms touch one tree, so the
// order dependence is measured rather than assumed.
package pk14_54;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s14_t;
endpackage
interface if14_54;
  logic [7:0] bus;
  pk14_54::s14_t st;
endinterface
module snk14_54 (input [7:0] a, output [7:0] o);
  assign o = ~a;
endmodule
module mid14_54 (if14_54 ifp, input logic sel, output logic [7:0] o);
  logic [7:0] w1, w2;
  // hier_path (interface member) + nested replication in ONE actual
  snk14_54 u_ifm (.a({sel ? ifp.bus[3:0] : {4{1'b1}}, 4'h1}), .o(w1));
  // hier_path through an interface STRUCT member + nested replication
  snk14_54 u_ifs (.a({sel ? ifp.st.hi : {4{1'b0}}, 4'h2}), .o(w2));
  assign o = w1 ^ w2;
endmodule
module v14_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  if14_54 theif();
  pk14_54::s14_t st;
  logic [7:0] w3, w4, w5;
  assign st = d;
  assign theif.bus = d;
  // local struct member hier_path + nested replication
  snk14_54 u_stm (.a({sel ? st.hi : {4{1'b1}}, 4'h3}), .o(w3));
  // BOTH members and TWO replications
  snk14_54 u_two (.a({sel ? st.hi : {4{1'b0}}, sel ? {4{1'b1}} : st.lo}), .o(w4));
  mid14_54 u_mid (.ifp(theif), .sel(sel), .o(w5));
  assign q = w3 ^ w4 ^ w5;
endmodule
