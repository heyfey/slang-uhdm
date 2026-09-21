// r11u73 arm w4 — THE UNTYPED-MINUS SIZE ALONG A NAME CHAIN (LAW D, RV-3).
// § redUntypedIntNameSz72 reads 32 for an IMPLICITLY typed parameter with no
// dimensions whose initializer is a unary minus.  `v4_hop72` `c` showed the
// rule does not follow a NAME chain: `MD = -16'd5`, `HOP1 = MD`, `HOP2 = HOP1`
// is golden 32 and ours 16.  This arm asks how far the chain carries and WHAT
// it carries: does an untyped name onto a BASED literal keep the literal's
// width (so the 32 belongs to the minus), or does every untyped hop read 32?
// Operand 0 is a guaranteed bail (`8'hxA`), so every operand after it prints
// `reduceExpr`'s OWN size against 24-bit members that collide with nothing.
// Each member read EXACTLY ONCE.
package q4;
  localparam            MD   = -16'd5;   // untyped minus       golden 32
  localparam            HOP1 = MD;       // 1 hop
  localparam            HOP2 = HOP1;     // 2 hops
  localparam            HOP3 = HOP2;     // 3 hops
  localparam            UH16 = 16'h28;   // untyped based hex   golden 16
  localparam            HH1  = UH16;     // 1 hop onto a based literal
  localparam            HH2  = HH1;      // 2 hops onto a based literal
  localparam            UD16 = 16'd9;    // untyped based dec   golden 16
  localparam            HD1  = UD16;     // 1 hop onto a based decimal
  localparam byte       TB   = 8'sd7;    // TYPED byte          golden 8
  localparam            HT1  = TB;       // 1 hop onto a TYPED name
  localparam bit [15:0] WD   = -16'd5;   // TYPED 16, minus initializer
  localparam            HW1  = WD;       // 1 hop onto a typed-16 name
  localparam            AR   = 16'd9 + 16'd1; // untyped, ARITHMETIC initializer
  localparam            HA1  = AR;       // 1 hop onto an arithmetic name
  localparam            NB   = -8'd3;    // untyped minus over an 8-bit
  localparam            HN1  = NB;
  localparam            HN2  = HN1;
  localparam            MU   = -UH16;    // untyped minus over a NAME
  localparam            HU1  = MU;       // 1 hop onto that
  localparam int        K    = 6;
  typedef struct packed {
    logic [23:0] bail;  // 8'hxA   GUARANTEED BAIL
    logic [23:0] a;     // MD      32 expected (the landed rule)
    logic [23:0] b;     // HOP1    32 or 16?
    logic [23:0] c;     // HOP2    32 or 16?   (v4_hop72 `c`: golden 32)
    logic [23:0] d;     // HOP3    32 or 16?
    logic [23:0] e;     // UH16    16 expected
    logic [23:0] f;     // HH1     16 or 32?   <- decides what the chain carries
    logic [23:0] g;     // HH2     16 or 32?
    logic [23:0] h;     // UD16    16 expected
    logic [23:0] i;     // HD1     16 or 32?
    logic [23:0] j;     // TB      8 expected
    logic [23:0] k;     // HT1     8 or 32?
    logic [23:0] l;     // WD      16 expected (typed)
    logic [23:0] m;     // HW1     16 or 32?
    logic [23:0] n;     // -HOP2   the minus over a hopped name
    logic [23:0] o;     // AR      32 or 16?   the arithmetic origin
    logic [23:0] p;     // HA1     32 or 16?
    logic [23:0] q;     // NB      32 expected
    logic [23:0] r;     // HN1     32 or 8?
    logic [23:0] s;     // HN2     32 or 8?
    logic [23:0] t;     // MU      32 expected (minus over a name)
    logic [23:0] u;     // HU1     32 or 16?
    logic [23:0] v;     // K       32 expected  CONTROL
  } c4_t;
  localparam c4_t A4 = '{bail: 8'hxA, a: MD, b: HOP1, c: HOP2, d: HOP3,
                         e: UH16, f: HH1, g: HH2, h: UD16, i: HD1, j: TB,
                         k: HT1, l: WD, m: HW1, n: -HOP2, o: AR, p: HA1,
                         q: NB, r: HN1, s: HN2, t: MU, u: HU1, v: K};
endpackage
module w4_hop73 #(parameter q4::c4_t C = q4::A4)
                (output logic [23:0] y0,  output logic [23:0] y1,
                 output logic [23:0] y2,  output logic [23:0] y3,
                 output logic [23:0] y4,  output logic [23:0] y5,
                 output logic [23:0] y6,  output logic [23:0] y7,
                 output logic [23:0] y8,  output logic [23:0] y9,
                 output logic [23:0] y10, output logic [23:0] y11,
                 output logic [23:0] y12, output logic [23:0] y13,
                 output logic [23:0] y14, output logic [23:0] y15,
                 output logic [23:0] y16, output logic [23:0] y17,
                 output logic [23:0] y18, output logic [23:0] y19,
                 output logic [23:0] y20, output logic [23:0] y21,
                 output logic [23:0] y22);
  assign y0 = C.bail; assign y1 = C.a;  assign y2 = C.b;  assign y3 = C.c;
  assign y4 = C.d;    assign y5 = C.e;  assign y6 = C.f;  assign y7 = C.g;
  assign y8 = C.h;    assign y9 = C.i;  assign y10 = C.j; assign y11 = C.k;
  assign y12 = C.l;   assign y13 = C.m; assign y14 = C.n; assign y15 = C.o;
  assign y16 = C.p;   assign y17 = C.q; assign y18 = C.r; assign y19 = C.s;
  assign y20 = C.t;   assign y21 = C.u; assign y22 = C.v;
endmodule
