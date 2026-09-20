// v11u56 ADVERSARIAL arm x1 — THE REST OF THE REDUCE-TABLE OPERATOR SET.
// e1_enc56 grids +, -, << only; dimRedCtExpr79 also CLAIMS *, /, %, **, >>,
// >>>, &, | and a $ call, and ABSTAINS on ^, comparisons, concat, ternary,
// cast and a unary ~.  Every member is read EXACTLY ONCE.
package p;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  typedef struct packed {
    logic [31:0] mul;    // K * 2
    logic [31:0] dvd;    // K / 2
    logic [31:0] mod;    // K % 4
    logic [31:0] pwr;    // K ** 2
    logic [31:0] shr;    // KU >> 1
    logic [31:0] asr;    // K >>> 1
    logic [31:0] ban;    // KU & 3
    logic [31:0] bor;    // KU | 8
    logic [31:0] bxr;    // KU ^ 3        (table ABSTAINS)
    logic [31:0] cmp;    // K > 2         (table ABSTAINS)
    logic [15:0] cat;    // {8'd1, 8'd2}  (table ABSTAINS)
    logic [31:0] ter;    // K ? 3 : 4     (table ABSTAINS)
    logic [31:0] cst;    // int'(K)       (table ABSTAINS)
    logic [31:0] clg;    // $clog2(40)
    logic signed [31:0] nmul;  // -(K * 2)
    logic [31:0] negs;   // 2 - 5   (negative out of a subtract, UNSIGNED member)
    logic [31:0] zsub;   // K - K   (a ZERO out of an INT arm)
    logic signed [31:0] nzer;  // -0   (unary minus over zero)
    logic [63:0] bigs;   // KU << 40
    logic [31:0] notu;   // ~KU     (table ABSTAINS)
  } cfg_t;
  localparam cfg_t LIT = '{mul: K * 2, dvd: K / 2, mod: K % 4, pwr: K ** 2,
                           shr: KU >> 1, asr: K >>> 1, ban: KU & 3, bor: KU | 8,
                           bxr: KU ^ 3, cmp: K > 2, cat: {8'd1, 8'd2},
                           ter: K ? 3 : 4, cst: int'(K), clg: $clog2(40),
                           nmul: -(K * 2), negs: 2 - 5, zsub: K - K, nzer: -0,
                           bigs: KU << 40, notu: ~KU};
endpackage
module dut #(parameter p::cfg_t C = p::LIT)
           (output logic [31:0] o01, output logic [31:0] o02,
            output logic [31:0] o03, output logic [31:0] o04,
            output logic [31:0] o05, output logic [31:0] o06,
            output logic [31:0] o07, output logic [31:0] o08,
            output logic [31:0] o09, output logic [31:0] o10,
            output logic [31:0] o11, output logic [31:0] o12,
            output logic [31:0] o13, output logic [31:0] o14,
            output logic signed [31:0] o15, output logic [31:0] o16,
            output logic [31:0] o17, output logic signed [31:0] o18,
            output logic [63:0] o19, output logic [31:0] o20);
  assign o01 = C.mul;  assign o02 = C.dvd;  assign o03 = C.mod;
  assign o04 = C.pwr;  assign o05 = C.shr;  assign o06 = C.asr;
  assign o07 = C.ban;  assign o08 = C.bor;  assign o09 = C.bxr;
  assign o10 = C.cmp;  assign o11 = C.cat;  assign o12 = C.ter;
  assign o13 = C.cst;  assign o14 = C.clg;  assign o15 = C.nmul;
  assign o16 = C.negs; assign o17 = C.zsub; assign o18 = C.nzer;
  assign o19 = C.bigs; assign o20 = C.notu;
endmodule
