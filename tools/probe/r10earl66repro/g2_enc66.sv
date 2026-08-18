// r10earl66 GRID ARM 2 — the ENCODING half: what exactly does golden put in
// the folded constant (VpiValue / VpiConstType / VpiSize / VpiDecompile) for
// every way an enum member can get its value, plus the $unit enum, the
// multi-instance repeat, and a PACKAGE PARAMETER read in the same positions.
// MEASUREMENT ONLY.
typedef enum logic [1:0] { UN0 = 2'h1, UN1 = 2'h2 } unit_e;   // $unit enum

package pe66b;
  localparam int PLP = 5;                       // package localparam
  parameter  int PPP = 7;                       // package parameter
  typedef enum logic [2:0]  { XA = 3'h2 + 3'h1 } expr_e;      // EXPRESSION-valued
  typedef enum logic signed [3:0] { XN = -3 }   neg_e;        // NEGATIVE
  typedef enum logic [39:0] { XW = 40'h12_3456_789A } wide_e; // >32 bits
  typedef enum logic [7:0]  { XS = 8'sd9 }      sgn_e;        // SIGNED literal
  typedef enum logic [4:0]  { XO = 5'o17 }      oct_e;        // OCTAL
  typedef enum logic [2:0]  { XP = PLP[2:0] }   par_e;        // from a localparam
endpackage

module leaf66b (
  input  logic [63:0] a_i,
  output logic        o_o
);
  assign o_o = ^a_i;
endmodule

module g2_enc66 import pe66b::*; (
  input  logic [63:0] d_i,
  output logic [15:0] o_o
);
  // ELAB High_conn bit-select index, one per encoding
  leaf66b u_expr (.a_i(64'(d_i[XA])), .o_o(o_o[0]));
  leaf66b u_wide (.a_i(64'(d_i[XW[2:0]])), .o_o(o_o[1]));
  leaf66b u_sgn  (.a_i(64'(d_i[XS])), .o_o(o_o[2]));
  leaf66b u_oct  (.a_i(64'(d_i[XO])), .o_o(o_o[3]));
  leaf66b u_par  (.a_i(64'(d_i[XP])), .o_o(o_o[4]));
  leaf66b u_unit (.a_i(64'(d_i[UN1])), .o_o(o_o[5]));
  // the NEGATIVE member as a bare actual (a select on it would be illegal)
  leaf66b u_neg  (.a_i(64'(XN)), .o_o(o_o[6]));
  leaf66b u_widea(.a_i(64'(XW)), .o_o(o_o[7]));
  // PACKAGE PARAMETER / LOCALPARAM in the same positions (rgg11/earl64 law)
  leaf66b u_plp  (.a_i(64'(d_i[PLP])), .o_o(o_o[8]));
  leaf66b u_ppp  (.a_i(64'(d_i[PPP])), .o_o(o_o[9]));
  leaf66b u_plpa (.a_i(64'(PLP)), .o_o(o_o[10]));
  // THREE instances of the same shape (object sharing vs copying)
  leaf66b u_r1 (.a_i(64'(d_i[XA])), .o_o(o_o[11]));
  leaf66b u_r2 (.a_i(64'(d_i[XA])), .o_o(o_o[12]));
  leaf66b u_r3 (.a_i(64'(d_i[XA])), .o_o(o_o[13]));
  assign o_o[15:14] = 2'b0;
endmodule
