// r11v96 VERIFIER arm v3 — LAW C AND THE REPLICATION FACE, BREAKERS.  The
// kind-1 gate declines on ANY concatenation ANYWHERE in the initializer's
// syntax, and the replication gate writes NOTHING whenever the inner
// parameter's own top is a replication.  This arm holds the shapes neither
// y3 nor y5 carries: a concatenation under a CAST, under `$bits`, inside a
// comparison, inside a system call's argument; a SIGNED-declared kind-1
// replication; a replication with a PARAMETER repeat count; `{1{...}}`; a
// nested replication-of-replication; and the unsigned/signed reader of each.
package v3p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int                 RN   = 2;
  localparam int                 CCST = int'({4'd1, 4'd2});   // a CAST on top
  localparam int                 CBIT = $bits({4'd1, 4'd2});  // $bits of one
  localparam int                 CCMP = ({4'd1, 4'd2} == 8'd18) ? 7 : 9;
  localparam int                 CCLG = $clog2({4'd1, 4'd2}); // sys-call arg
  localparam logic signed [15:0] KRS  = {2{4'd3}};   // kind 1 SIGNED replic
  localparam logic signed [15:0] KCS  = {4'd1, 4'd2};// kind 1 SIGNED concat
  localparam int                 KRPC = {RN{4'd3}};  // PARAMETER repeat count
  localparam int                 KR1  = {1{4'd3}};   // a ONE-replication
  localparam int                 KRR2 = {2{{2{2'd1}}}};  // replic of replic
  localparam int                 KRCT = int'({2{4'd3}}); // a CAST on a replic
  localparam int                 CLIT = 8'd18;       // the control
endpackage
module v3_ctsbrk96v;
  localparam logic [7:0]         P1 = v3p::CCST;
  localparam logic signed [15:0] P2 = v3p::CCST;
  localparam logic [7:0]         P3 = v3p::CBIT;
  localparam logic signed [15:0] P4 = v3p::CBIT;
  localparam logic [7:0]         P5 = v3p::CCMP;
  localparam logic signed [15:0] P6 = v3p::CCMP;
  localparam logic [7:0]         P7 = v3p::CCLG;
  localparam logic signed [15:0] P8 = v3p::CCLG;
  localparam logic [7:0]         P9 = v3p::KRS;
  localparam logic signed [15:0] PA = v3p::KRS;
  localparam logic [7:0]         PB = v3p::KCS;
  localparam logic signed [15:0] PC = v3p::KCS;
  localparam logic [7:0]         PD = v3p::KRPC;
  localparam logic signed [15:0] PE = v3p::KRPC;
  localparam logic [7:0]         PF = v3p::KR1;
  localparam logic signed [15:0] PG = v3p::KR1;
  localparam logic [7:0]         PH = v3p::KRR2;
  localparam logic signed [15:0] PI = v3p::KRR2;
  localparam logic [7:0]         PJ = v3p::KRCT;
  localparam logic signed [15:0] PK = v3p::KRCT;
  localparam logic [7:0]         PL = v3p::CLIT;
  localparam logic signed [15:0] PM = v3p::CLIT;
  localparam v3p::t A = '{bail: 8'hxA, a: P1, b: P2, c: P3, d: P4,
                          e: P5, f: P6, g: P7};
  localparam v3p::t B = '{bail: 8'hxA, a: P8, b: P9, c: PA, d: PB,
                          e: PC, f: PD, g: PE};
  localparam v3p::t C = '{bail: 8'hxA, a: PF, b: PG, c: PH, d: PI,
                          e: PJ, f: PK, g: PL};
  localparam v3p::t D = '{bail: 8'hxA, a: PM, b: P9, c: PA, d: P1,
                          e: P2, f: PD, g: PE};
  v3_sink #(.R(A)) s1();
  v3_sink #(.R(B)) s2();
  v3_sink #(.R(C)) s3();
  v3_sink #(.R(D)) s4();
endmodule
module v3_sink #(parameter v3p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
