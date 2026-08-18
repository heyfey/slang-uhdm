// v65 ARM 1 — ELAB port High_conn ips bounds: EVERY package-parameter SHAPE.
// The law removes the typespec for a PACKAGE-param fold in an ips bound inside
// an ELABORATED port High_conn.  If golden keeps ANY typespec for ANY of these
// shapes, the removal is a regression.  MEASUREMENT ONLY.
package pa1;
  localparam       IMP  = 5;            // implicit type
  localparam int   INT  = 5;            // explicit signed int
  localparam integer ITG = 5;           // integer
  localparam bit [7:0]   BIT8 = 5;      // 2-state packed, unsigned
  localparam logic [7:0] LOG8 = 5;      // 4-state packed, unsigned
  localparam byte  BYT = 5;
  localparam shortint SHI = 5;
  localparam longint LNG = 5;
  typedef logic [7:0] w_t;
  localparam w_t   TDF  = 5;            // typedef'd
  typedef enum logic [3:0] { E0 = 0, E5 = 5 } e_t;
  localparam e_t   ENM  = E5;           // enum-typed
  parameter  int   PRM  = 5;            // package `parameter`, not localparam
  localparam int   NEG  = -5;           // negative (used as a BASE only)
  localparam int   B2   = 2;
endpackage

module l1 (input logic [31:0] a_i, input logic b_i, output logic o_o);
  assign o_o = ^a_i ^ b_i;
endmodule

module a1_origin import pa1::*; (input logic [127:0] d_i, output logic [15:0] o_o);
  // ips WIDTH, one instance per package-param shape
  l1 u_imp (.a_i(d_i[0 +: IMP ]), .b_i(d_i[0]), .o_o(o_o[0]));
  l1 u_int (.a_i(d_i[0 +: INT ]), .b_i(d_i[0]), .o_o(o_o[1]));
  l1 u_itg (.a_i(d_i[0 +: ITG ]), .b_i(d_i[0]), .o_o(o_o[2]));
  l1 u_bit (.a_i(d_i[0 +: BIT8]), .b_i(d_i[0]), .o_o(o_o[3]));
  l1 u_log (.a_i(d_i[0 +: LOG8]), .b_i(d_i[0]), .o_o(o_o[4]));
  l1 u_byt (.a_i(d_i[0 +: BYT ]), .b_i(d_i[0]), .o_o(o_o[5]));
  l1 u_shi (.a_i(d_i[0 +: SHI ]), .b_i(d_i[0]), .o_o(o_o[6]));
  l1 u_lng (.a_i(d_i[0 +: LNG ]), .b_i(d_i[0]), .o_o(o_o[7]));
  l1 u_tdf (.a_i(d_i[0 +: TDF ]), .b_i(d_i[0]), .o_o(o_o[8]));
  l1 u_enm (.a_i(d_i[0 +: ENM ]), .b_i(d_i[0]), .o_o(o_o[9]));
  l1 u_prm (.a_i(d_i[0 +: PRM ]), .b_i(d_i[0]), .o_o(o_o[10]));
  // ips BASE
  l1 u_bs1 (.a_i(d_i[B2 +: 32]), .b_i(d_i[0]), .o_o(o_o[11]));
  l1 u_bs2 (.a_i(d_i[INT +: 32]), .b_i(d_i[0]), .o_o(o_o[12]));
  // QUALIFIED spelling of the same read
  l1 u_qw  (.a_i(d_i[0 +: pa1::INT]), .b_i(d_i[0]), .o_o(o_o[13]));
  l1 u_qb  (.a_i(d_i[pa1::B2 +: 32]), .b_i(d_i[0]), .o_o(o_o[14]));
  // arithmetic bound (fold one operation deep)
  l1 u_ar  (.a_i(d_i[0 +: INT+1]), .b_i(d_i[0]), .o_o(o_o[15]));
endmodule
