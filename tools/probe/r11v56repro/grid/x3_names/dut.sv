// v11u56 ADVERSARIAL arm x3 — NAMES, NOT OPERATORS.  F2's else-branch writes
// the SETTER's own signed value; the fence only follows a NAME chain down to
// an IntegerVectorExpression.  These are the name shapes the pass-56 grid does
// not carry: a parameter that is ALREADY negative, a two-hop chain, a name
// whose init is a unary minus over a BASED literal (the fence does NOT see the
// base letter through the minus), a signed based decimal, and a name whose
// init is another name reading a based literal.
package p;
  localparam int  NEGK  = -6;          // already negative, no minus at the setter
  localparam int  P1    = 5;
  localparam int  P2    = P1 - 1;      // two hops, INT arm at the bottom
  localparam      MD    = -16'd5;      // unary minus OVER a based decimal
  localparam      SD    = 16'sd5;      // SIGNED based decimal
  localparam      HD    = 16'h28;      // based hex
  localparam      HH    = HD;          // a NAME reading a NAME reading 'h
  localparam int  NN    = NEGK;        // a NAME reading a negative NAME
  localparam int unsigned UBIG = 32'hFFFFFFFF;
  typedef struct packed {
    logic signed [31:0] nk;   // NEGK
    logic [31:0]        dk;   // P2
    logic signed [31:0] md;   // MD
    logic [15:0]        sd;   // SD     (fence: based)
    logic [15:0]        hh;   // HH     (fence: based through two names)
    logic signed [31:0] nn;   // NN
    logic [7:0]         nb;   // NEGK on an 8-BIT member
    logic [31:0]        ub;   // UBIG   (unsigned 32-bit all ones)
    logic signed [31:0] sub;  // UBIG - 1 (unsigned operands, INT arm)
  } cfg_t;
  localparam cfg_t LIT = '{nk: NEGK, dk: P2, md: MD, sd: SD, hh: HH,
                           nn: NN, nb: NEGK, ub: UBIG, sub: UBIG - 1};
endpackage
module dut #(parameter p::cfg_t C = p::LIT)
           (output logic signed [31:0] o1, output logic [31:0] o2,
            output logic signed [31:0] o3, output logic [15:0] o4,
            output logic [15:0] o5, output logic signed [31:0] o6,
            output logic signed [31:0] o7, output logic [31:0] o8,
            output logic signed [31:0] o9);
  assign o1 = C.nk;  assign o2 = C.dk;  assign o3 = C.md;
  assign o4 = C.sd;  assign o5 = C.hh;  assign o6 = C.nn;
  assign o7 = C.nb;  assign o8 = C.ub;  assign o9 = C.sub;
endmodule
