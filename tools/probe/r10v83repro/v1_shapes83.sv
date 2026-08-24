// r10v83 arm 1 — THE WRITTEN-CAST SHAPE MATRIX.  Every shape the verifier
// brief names, each the WHOLE actual of an ELABORATED port High_conn (a BARE
// actual: nesting a cast inside a concat makes golden fold the ENCLOSING
// expression, which leaves NO object at the cast span and scores nothing).
// MEASUREMENT ONLY.
typedef logic [11:0] tw83_t;
typedef bit   [3:0]  b4_83_t;
typedef enum logic [2:0] { EA83 = 3'd1, EB83 = 3'd2 } e83_t;

module snk83 (input logic [63:0] a, output logic [63:0] y);
  assign y = ~a;
endmodule

module snks83 (input string s, output logic [7:0] y);
  assign y = 8'(s.len());
endmodule

module v1_shapes83;
  localparam int P83 = 5;
  localparam int W83 = 12;
  localparam int A83 = 3;
  localparam int B83 = 4;
  logic [63:0] n0, n1, n2, n3, n4, n5, n6, n7, n8, n9;
  logic [63:0] na, nb, nc, nd, ne, nf, ng, nh, ni, nj, nk, nl, nm;
  logic [63:0] src;
  logic [7:0]  ys;

  snk83 u01 (.a(integer'(0)),          .y(n0));  // S01 integer'(0)   FOLD
  snk83 u02 (.a(int'(5)),              .y(n1));  // S02 int'(5)       abstain
  snk83 u03 (.a(byte'(300)),           .y(n2));  // S03 byte'(300)    abstain
  snk83 u04 (.a(b4_83_t'(4'd9)),       .y(n3));  // S04 typedef bit   abstain
  snk83 u05 (.a(shortint'(-1)),        .y(n4));  // S05 shortint'(-1) abstain
  snk83 u06 (.a(signed'(32'd7)),       .y(n5));  // S06 signed'       abstain
  snk83 u07 (.a(unsigned'(32'sd7)),    .y(n6));  // S07 unsigned'     abstain
  snk83 u08 (.a(tw83_t'(12'h5a5)),     .y(n7));  // S08 typedef logic abstain
  snk83 u09 (.a(integer'(P83)),        .y(n8));  // S09 integer'(P)   abstain
  snk83 u10 (.a(integer'(A83 + B83)),  .y(n9));  // S10 integer'(A+B) abstain
  snk83 u11 (.a(int'($clog2(64))),     .y(na));  // S11 int'($clog2)  abstain
  snk83 u12 (.a(integer'(integer'(9))),.y(nb));  // S12 cast of cast  abstain
  snk83 u13 (.a(W83'(0)),              .y(nc));  // S13 PARAM width   FOLD
  snk83 u14 (.a(8'(300)),              .y(nd));  // S14 literal width FOLD
  snk83 u15 (.a(1'(3)),                .y(ne));  // S15 width 1       FOLD
  snk83 u16 (.a(24'(24'hFFFFFF)),      .y(nf));  // S16 based hex     FOLD
  snk83 u17 (.a(16'(1'b1)),            .y(ng));  // S17 based bin     FOLD
  snk83 u18 (.a(8'(8'sd9)),            .y(nh));  // S18 SIGNED oper   abstain
  snk83 u19 (.a(32'(1'bx)),            .y(ni));  // S19 x literal     abstain
  snk83 u20 (.a(integer'(7)),          .y(nj));  // S20 unbased dec 7 FOLD
  snk83 u21 (.a(e83_t'(3'd2)),         .y(nk));  // S21 enum target   abstain
  snk83 u22 (.a(64'(64'hFFFFFFFFFFFFFFFF)), .y(nl)); // S23 W=64      abstain
  snk83 u23 (.a(63'(64'hFFFFFFFFFFFFFFFF)), .y(nm)); // S24 W=63      FOLD
  snks83 u24 (.s({"ab", string'("cd")}),    .y(ys)); // S25 str concat MUST STAY

  assign src = n0^n1^n2^n3^n4^n5^n6^n7^n8^n9^na^nb^nc^nd^ne^nf^ng^nh^ni^nj^nk^nl^nm^{56'd0,ys};
endmodule
