// r10v68 arm v2 — the LHS-TYPE ladder EXTENDED past a2_lhs68: the widths
// r10earl68's caLhsAdjustSize68 decides (bit widths at and around the 64
// boundary, 2-state, signed, packed struct WHOLE, longint/time, shortint,
// shortreal, an unpacked-array element, a hierarchical/interface Lhs, and a
// NEGATIVE genvar value).  MEASUREMENT ONLY.
interface v2_if68;
  logic [7:0] a;
endinterface

typedef struct packed { logic [3:0] hi; logic [3:0] lo; } v2_st68;
typedef struct packed { logic [15:0] w; logic [15:0] x; } v2_wide68;

module v2_lhs68 (input logic [7:0] din, output logic [7:0] dout);
  logic [62:0]  b63;
  logic [63:0]  b64;
  logic [64:0]  b65;
  logic [127:0] b128;
  bit   [7:0]   t8;
  logic signed [7:0] s8;
  shortint      sh;
  longint       lg;
  time          tm;
  v2_st68       st;
  v2_wide68     stw;
  shortreal     sr;
  real          rl;
  logic [7:0]   ua [0:7];
  logic [7:0]   n8v, n5v, n3v, n1v;
  logic [7:0]   neg8;

  // 13 unrollings so every masking case sees a value wider than its target.
  for (genvar i = 0; i < 13; i++) begin : g_t
    if (i >= 0) begin : b1
      if (i == 1)  begin : c63  assign b63  = i; end
      if (i == 2)  begin : c64  assign b64  = i; end
      if (i == 3)  begin : c65  assign b65  = i; end
      if (i == 4)  begin : c128 assign b128 = i; end
      if (i == 5)  begin : ct8  assign t8   = i; end
      if (i == 6)  begin : cs8  assign s8   = i; end
      if (i == 7)  begin : csh  assign sh   = i; end
      if (i == 8)  begin : clg  assign lg   = i; end
      if (i == 9)  begin : ctm  assign tm   = i; end
      if (i == 10) begin : cst  assign st   = i; end
      if (i == 11) begin : cstw assign stw  = i; end
      if (i == 12) begin : csr  assign sr   = i; end
      if (i == 0)  begin : crl  assign rl   = i; end
    end
  end

  // MASKING ladder: one target width, values that exceed it.
  for (genvar i = 5; i < 9; i++) begin : g_m
    if (i == 5) begin : m5 assign n5v[4:0] = i; end   // part-select Lhs
    if (i == 6) begin : m6 assign n1v      = i; end   // 8-bit target
    if (i == 7) begin : m7 assign ua[0]    = i; end   // unpacked elem
    if (i == 8) begin : m8 assign n3v      = i; end
  end

  // NEGATIVE genvar values.
  for (genvar i = -3; i < 0; i++) begin : g_neg
    if (i < 0) begin : b1
      assign neg8 = i;                                // negative whole Rhs
    end
  end

  // hierarchical / interface Lhs.
  v2_if68 the_if ();
  for (genvar i = 1; i < 2; i++) begin : g_h
    if (i >= 0) begin : b1
      assign the_if.a = i;                            // interface member Lhs
    end
  end

  assign dout = b63[7:0] ^ b64[7:0] ^ b65[7:0] ^ b128[7:0] ^ t8 ^ s8 ^
                sh[7:0] ^ lg[7:0] ^ tm[7:0] ^ {st.hi, st.lo} ^ stw.w[7:0] ^
                ua[0] ^ n5v ^ n1v ^ n3v ^ n8v ^ neg8 ^ the_if.a ^ din;
endmodule
