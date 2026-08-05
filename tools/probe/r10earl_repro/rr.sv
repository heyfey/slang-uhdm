// r10earl6 rr.sv — 4 of the 5 remaining AllPackages heads, all one shape:
// a PACKAGE localparam whose initialiser reads ANOTHER package (or its own
// earlier localparams) stays SYMBOLIC in golden's DEF (uhdmallPackages)
// listing where we fold it to a constant.
//     rstmgr_pkg.sv:8    localparam int ExtResetReasons = pwrmgr_pkg::HwRstReqs
//         failLhs ref_obj 'pwrmgr_pkg::HwRstReqs'   failRhs <null>
//     flash_phy_pkg.sv:17 parameter int DataWidth  = flash_ctrl_pkg::DataWidth
//     alert_pkg.sv:9      localparam int unsigned NAlerts
//                                       = alert_handler_reg_pkg::NAlerts
//     flash_ctrl_pkg.sv:18 localparam int AddrW = BankW + PageW + WordW
//         failLhs operation ''  (the three operands are SAME-package
//         localparams, each of them a $clog2 fold)
// Every one is a param_assign Rhs in a top=0 package listing.
package ra;
  parameter  int AP = 4;
  localparam int AL = 6;
  localparam int ACLOG = $clog2(16);
endpackage

package rb;
  // row A — a `parameter` reading another package's PARAMETER
  parameter  int X = ra::AP;
  // row B — a `localparam` reading another package's LOCALPARAM
  localparam int Y = ra::AL;
  // row C — a cross-package read inside an OPERATION
  localparam int Z = ra::AP + 1;
  // row D — a SAME-package chain over $clog2 folds (the flash_ctrl shape)
  localparam int C1 = $clog2(16);
  localparam int C2 = $clog2(8);
  localparam int SUM = C1 + C2;
  // row E — a plain literal (control)
  localparam int LIT = 12;
  // row F — a SAME-package read of a plain literal localparam (control)
  localparam int ECHO = LIT;
endpackage

module rchild (input logic [3:0] i, output logic [31:0] o);
  assign o = i + rb::X + rb::Y + rb::Z + rb::SUM + rb::LIT + rb::ECHO;
endmodule

module rr (input logic [3:0] i, output logic [31:0] o);
  rchild u_r (.i(i), .o(o));
endmodule
