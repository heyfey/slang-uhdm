// r11u96 arm y3 — LAW C, the CONCAT class under an EXPLICIT declared type
// (`red91PkgDeclKind91` kind 1).  The same producer fact the verified
// § pkgSynConcatKeepsNoTs94v landed for kind 2: the declared typespec never
// reaches the elaborated constant of a parameter whose initializer holds a
// concatenation or a replication, the clone is bare, and the READER votes.
// Both faces are here — a SIGNED package type read by an UNSIGNED hop (golden
// writes NO typespec where we write one) and an UNSIGNED package type read by
// a SIGNED hop (golden writes the READER's where we write none) — with the
// nestings, the chain, and the kind-1 controls that must not move.
package y3p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int                 JC   = {4'd1, 4'd2};
  localparam logic [7:0]         JU   = {4'd1, 4'd2};
  localparam logic signed [15:0] JS   = {4'd1, 4'd2};
  localparam int                 JR   = {2{4'd3}};
  localparam int                 JN   = {4'd1, 4'd2} + 0;
  localparam int                 JTC  = 1 ? {4'd1, 4'd2} : 8'd0;
  localparam int                 JSC  = {4'd1, 4'd2} >> 1;
  localparam int                 JCH  = JC;
  // the kind-1 CONTROLS — no concatenation anywhere in the initializer
  localparam int                 JLIT = 8'd18;
  localparam int                 JOP  = 3 + 4;
  localparam int                 JHX  = 8'h1A;
  localparam logic [7:0]         JDU  = 8'd18;
endpackage
module y3_kind1cat96;
  localparam logic [7:0]         N1 = y3p::JC;
  localparam logic signed [15:0] N2 = y3p::JC;
  localparam logic signed [15:0] N3 = y3p::JU;
  localparam logic [7:0]         N4 = y3p::JU;
  localparam logic [7:0]         N5 = y3p::JR;
  localparam logic [7:0]         N6 = y3p::JN;
  localparam logic [7:0]         N7 = y3p::JTC;
  localparam logic [7:0]         N8 = y3p::JSC;
  localparam logic [7:0]         N9 = y3p::JCH;
  localparam logic signed [15:0] NA = y3p::JS;
  localparam logic [7:0]         NB = y3p::JLIT;
  localparam logic [7:0]         NC = y3p::JOP;
  localparam logic [7:0]         ND = y3p::JHX;
  localparam logic signed [15:0] NE = y3p::JDU;
  localparam logic [7:0]         NF = y3p::JS;
  localparam logic signed [15:0] NG = y3p::JR;
  localparam y3p::t A = '{bail: 8'hxA, a: N1, b: N2, c: N3, d: N4,
                          e: N5, f: N6, g: N7};
  localparam y3p::t B = '{bail: 8'hxA, a: N8, b: N9, c: NA, d: NB,
                          e: NC, f: ND, g: NE};
  localparam y3p::t C = '{bail: 8'hxA, a: NF, b: NG, c: N1, d: N3,
                          e: NB, f: NE, g: N6};
  y3_sink #(.R(A)) s1();
  y3_sink #(.R(B)) s2();
  y3_sink #(.R(C)) s3();
endmodule
module y3_sink #(parameter y3p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
