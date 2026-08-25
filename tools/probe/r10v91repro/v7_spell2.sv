// r10v91 arm 7 — the last SPELLING faces: an inline dim over a typedef'd
// unpacked element, typedef chains through packages, and a pattern whose
// operand 0 is a hier_path WIDER / NARROWER than the element.
package p7;
  typedef logic [11:0] wd_t;
  typedef logic [11:0] wa_t [2];
  typedef wa_t         wb_t;
  typedef struct packed { logic [19:0] w; } big_t;
endpackage

module v7_spell2 (input logic [11:0] din, input logic [19:0] wide, output logic [11:0] q);
  import p7::*;
  logic [11:0] v12; assign v12 = din;
  big_t bg;         assign bg = big_t'(wide);

  // 1  INLINE dim over a TYPEDEF'd UNPACKED ARRAY element (array of arrays)
  wa_t  a1 [2];
  assign a1 = '{'{v12,din}, '{din,v12}};
  // 2  typedef chain (wb_t -> wa_t)  MUST KEEP
  wb_t  a2;  assign a2 = '{v12, din};
  // 3  inline unpacked whose element is a typedef'd SCALAR type
  wd_t  a3 [2]; assign a3 = '{v12, din};
  // 4  operand 0 WIDER than the element (must truncate)
  logic [11:0] a4 [2]; assign a4 = '{bg.w, din};
  // 5  operand 0 NARROWER than the element (must extend)
  logic [19:0] a5 [2]; assign a5 = '{v12, 20'd1};
  // 6  a 1-bit target with a 12-bit operand 0
  logic a6 [2]; assign a6 = '{v12[0], din[1]};
  // 7  32-bit (int) element with a 12-bit hier_path operand 0
  int   a7 [2]; assign a7 = '{bg.w, 3};
  // 8  a SIGNED element with a signed operand
  logic signed [11:0] sv; assign sv = din;
  logic signed [11:0] a8 [2]; assign a8 = '{sv, din};
  // 9  an inline unpacked array of an inline unpacked array (2 levels)
  logic [11:0] a9 [2][2]; assign a9 = '{'{v12,din},'{din,v12}};

  assign q = a1[0][0]^a2[0]^a3[0]^a4[0]^a5[0][11:0]^{11'd0,a6[0]}^a7[0][11:0]^a8[0]^a9[0][0];
endmodule
