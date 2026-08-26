// r10v96 adversarial arm v5 -- ELEMENT KINDS beside the logic-vector one the
// head used: an ENUM typedef, a PACKED STRUCT typedef, a PACKED ARRAY typedef,
// a TYPEDEF-OF-A-TYPEDEF, a two-state BIT vector typedef, a SIGNED vector
// typedef, a MULTI-DIMENSIONAL unpacked array, and a CONCAT-initialised
// parameter (the unpArrConcatTs9 half of the arm).  MEASUREMENT ONLY.
package p5k96;
  typedef logic [31:0]        v_t;
  typedef v_t                 vv_t;              // typedef OF a typedef
  typedef enum logic [1:0]  { E0, E1, E2 } e_t;
  typedef struct packed { logic [15:0] a; logic [15:0] b; } sp_t;
  typedef logic [3:0][7:0]    pa_t;              // PACKED ARRAY
  typedef bit  [31:0]         b_t;               // TWO-STATE
  typedef logic signed [31:0] sg_t;              // SIGNED
  localparam v_t  VARR  [4] = '{ 32'h1, 32'h2, 32'h3, 32'h4 };
  localparam vv_t VVARR [2] = '{ 32'h5, 32'h6 };
  localparam e_t  EARR  [3] = '{ E0, E1, E2 };
  localparam sp_t SARR  [2] = '{ '{a:16'h1, b:16'h2}, '{a:16'h3, b:16'h4} };
  localparam pa_t PARR  [2] = '{ 32'h11223344, 32'h55667788 };
  localparam b_t  BARR  [2] = '{ 32'h9, 32'ha };
  localparam sg_t GARR  [2] = '{ 32'hb, 32'hc };
  localparam v_t  MDARR [2][3] = '{ '{32'h1,32'h2,32'h3}, '{32'h4,32'h5,32'h6} };
endpackage

module m5k96 import p5k96::*; (output logic [31:0] o_o);
  localparam v_t  LV   [2] = '{ 32'h21, 32'h22 };
  localparam vv_t LVV  [2] = '{ 32'h23, 32'h24 };
  localparam e_t  LE   [2] = '{ E1, E2 };
  localparam sp_t LS   [2] = '{ '{a:16'h5, b:16'h6}, '{a:16'h7, b:16'h8} };
  localparam pa_t LP   [2] = '{ 32'hdeadbeef, 32'hcafebabe };
  localparam b_t  LB   [2] = '{ 32'h25, 32'h26 };
  localparam sg_t LG   [2] = '{ 32'h27, 32'h28 };
  localparam v_t  LMD  [2][3] = '{ '{32'h7,32'h8,32'h9}, '{32'ha,32'hb,32'hc} };
  localparam v_t  LCAT [2] = { 32'h31, 32'h32 };            // CONCAT init
  assign o_o = LV[0] ^ LVV[1] ^ {30'h0, LE[0]} ^ LS[1] ^ LP[0] ^ LB[1] ^
               LG[0] ^ LMD[1][2] ^ LCAT[1] ^
               VARR[0] ^ VVARR[1] ^ {30'h0, EARR[2]} ^ SARR[0] ^ PARR[1] ^
               BARR[0] ^ GARR[1] ^ MDARR[0][1];
endmodule

module top5k96 (output logic [31:0] a_o);
  m5k96 u_k (.o_o(a_o));
endmodule
