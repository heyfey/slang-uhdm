// r11u91 arm n1 — THE NEGATIVE PACKAGE LOCALPARAM'S RENDER (pass-87's R3,
// `q12_ndaparamenc`'s only head).  `§ pkgParamFoldWidthAlways` writes
// `"UINT:" + digits` unconditionally, and `UINT:-3` SERIALIZES AS ZERO, so a
// negative package parameter read anywhere reaches the database as `UINT:0`
// wearing a `-3` decompile.  Ten written forms, three reading homes.
package np;
  localparam int                PN    = -3;
  localparam int                PP    = 3;            // the POSITIVE control
  localparam logic signed [7:0] PN8   = -3;
  localparam logic [7:0]        PNU   = -3;           // an UNSIGNED declaration
  localparam byte               PNB   = -3;
  localparam longint            PNL   = -3;
  localparam                    PNIM  = -3;           // implicit
  localparam int                PNE   = 0 - 3;        // an operation
  localparam int                PNMIN = -2147483647;
  localparam int                PNZ   = -0;           // negative zero
endpackage
interface nifc ();
  wire signed [31:0] w_pn    = np::PN;
  wire signed [31:0] w_pp    = np::PP;
  wire signed [31:0] w_pn8   = np::PN8;
  wire signed [31:0] w_pnu   = np::PNU;
  wire signed [31:0] w_pnb   = np::PNB;
  wire signed [63:0] w_pnl   = np::PNL;
  wire signed [31:0] w_pnim  = np::PNIM;
  wire signed [31:0] w_pne   = np::PNE;
  wire signed [31:0] w_pnmin = np::PNMIN;
  wire signed [31:0] w_pnz   = np::PNZ;
endinterface
module dut (output logic [31:0] o);
  nifc u_if ();
  wire signed [31:0] m_pn = np::PN;              // the MODULE net-decl home
  wire signed [31:0] m_pnb;
  assign m_pnb = np::PNB;                        // a WRITTEN assign
  localparam logic signed [31:0] L_PN = np::PN;  // a PARAMETER read
  assign o = u_if.w_pn ^ u_if.w_pp ^ u_if.w_pn8 ^ u_if.w_pnu ^ u_if.w_pnb ^
             u_if.w_pnl[31:0] ^ u_if.w_pnim ^ u_if.w_pne ^ u_if.w_pnmin ^
             u_if.w_pnz ^ m_pn ^ m_pnb ^ L_PN;
endmodule
