// r11u75 g2 — LAW B: THE PACKAGE-HOMED NAMESAKE, IMPORT SHAPE BY IMPORT
// SHAPE.  r11v71's `w8_unitname` `gp` (an EXPLICIT import) and r11v74's
// `v6_ifacepkg` (a WILDCARD import) both say golden binds a gen-scope cell to
// a package variable; slang's `Scope::find` answers `nullptr` for an
// ExplicitImport and (differently) for a wildcard.  This arm separates the
// shapes and asks WHAT OBJECT golden binds: a module-level holder Surelog
// materialises for the import, or the package's own variable.
package pw;
  logic [15:0] w_ns;          // wildcard-imported, 16 bits (WIDTH question)
  logic [31:0] w_same;        // wildcard-imported, same width as the target
  wire  [31:0] w_net;         // a package NET
  localparam int W_PAR = 7;   // a package PARAMETER namesake
endpackage

package pe;
  logic [15:0] e_ns;          // explicitly imported
endpackage

package pu;
  logic [15:0] u_ns;          // NEVER imported — the negative control
endpackage

logic [7:0] unitname;         // $unit-scope namesake

module dut (output logic [31:0] o);
  import pw::*;
  import pe::e_ns;
  for (genvar i = 0; i < 1; i = i + 1) begin : gw
    logic [31:0] w_ns;    assign w_ns    = 32'd1;   // wildcard, 16-bit home
    logic [31:0] w_same;  assign w_same  = 32'd2;   // wildcard, 32-bit home
    logic [31:0] w_net;   assign w_net   = 32'd3;   // wildcard, a package NET
    logic [31:0] W_PAR;   assign W_PAR   = 32'd4;   // wildcard, a PARAMETER
    logic [31:0] e_ns;    assign e_ns    = 32'd5;   // EXPLICIT import
    logic [31:0] u_ns;    assign u_ns    = 32'd6;   // not imported: UNBOUND
    logic [31:0] unitname; assign unitname = 32'd7; // $unit: r11v69 says none
  end
  assign o = gw[0].w_ns ^ gw[0].w_same ^ gw[0].w_net ^ gw[0].W_PAR
           ^ gw[0].e_ns ^ gw[0].u_ns ^ gw[0].unitname;
endmodule
