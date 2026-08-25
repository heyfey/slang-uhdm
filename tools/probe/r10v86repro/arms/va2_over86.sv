// r10v86 va2 — OVERRIDDEN parameters as SUBTREE LEAVES, x 3 instances with
// DIFFERENT overrides, x package parameters, x header-declared implicit-signed
// parameters.  earl85's leaf fold gives an OVERRIDDEN param a WIDE (64) bare
// constant and NO typespec; earl86's arms then read that VpiSize/VpiConstType.
// GOLDEN = Surelog.  MEASUREMENT ONLY.
package v86b_pkg;
  parameter int PKI = 3;
  localparam int PKL = 6;
  localparam logic [7:0] PKW = 8'd4;
  localparam signed [7:0] PKS = 8'sd5;
endpackage

module v86_ov #(parameter int OVI  = 3,
                parameter logic [7:0] OVL = 8'd2,
                parameter bit signed [7:0] OVB = 8'sd1,
                parameter OVU = 4,
                parameter signed [7:0] OVS = 8'sd7,
                parameter signed OVR = 9,
                parameter int AddrW = 17) ();
  import v86b_pkg::*;
  localparam int P = 8;
  localparam int W = 5;

  // --- an OVERRIDDEN leaf in a foldable subtree ---------------------------
  localparam logic[AddrW-1:0] c_oi = ~(('h1 << (OVI + W)) - 1'b1);
  localparam logic[AddrW-1:0] c_ol = ~(('h1 << (OVL + W)) - 1'b1);
  localparam logic[AddrW-1:0] c_ob = ~(('h1 << (OVB + W)) - 1'b1);
  localparam logic[AddrW-1:0] c_ou = ~(('h1 << (OVU + W)) - 1'b1);
  localparam logic[AddrW-1:0] c_os = ~(('h1 << (OVS + W)) - 1'b1);
  localparam logic[AddrW-1:0] c_or = ~(('h1 << (OVR + W)) - 1'b1);
  // --- BOTH operands overridden -------------------------------------------
  localparam logic[AddrW-1:0] c_oo = ~(('h1 << (OVI + OVU)) - 1'b1);
  // --- an OVERRIDDEN leaf read BARE (earl85's leaf form must survive) ------
  localparam logic[AddrW-1:0] c_ob1 = ~(('h1 << OVI) - 1'b1);
  // --- unary over an overridden leaf --------------------------------------
  localparam logic[AddrW-1:0] c_ong = ~(('h1 << (~OVL)) - 1'b1);
  localparam logic[AddrW-1:0] c_omn = ~(('h1 << (-OVI + 40)) - 1'b1);
  // --- PACKAGE leaves, bare and qualified ---------------------------------
  localparam logic[AddrW-1:0] c_pk1 = ~(('h1 << (PKI + W)) - 1'b1);
  localparam logic[AddrW-1:0] c_pk2 = ~(('h1 << (v86b_pkg::PKL + W)) - 1'b1);
  localparam logic[AddrW-1:0] c_pk3 = ~(('h1 << (PKW + PKL)) - 1'b1);
  localparam logic[AddrW-1:0] c_pk4 = ~(('h1 << (v86b_pkg::PKS + 1)) - 1'b1);
  localparam logic[AddrW-1:0] c_pk5 = ~(('h1 << (PKI + v86b_pkg::PKL)) - 1'b1);
  // --- mixed overridden + package -----------------------------------------
  localparam logic[AddrW-1:0] c_mx  = ~(('h1 << (OVI + PKI)) - 1'b1);
  // --- header implicit-signed leaf read BARE through a ^ carrier ----------
  localparam logic[AddrW-1:0] c_xs  = ~(('h1 << (OVS ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] c_xr  = ~(('h1 << (OVR ^ 1)) - 1'b1);
endmodule

module top86_v2 ();
  v86_ov #(.OVI(3), .OVL(8'd2), .OVB(8'sd1), .OVU(4), .OVS(8'sd7), .OVR(9),  .AddrW(17)) i0 ();
  v86_ov #(.OVI(6), .OVL(8'd5), .OVB(8'sd2), .OVU(7), .OVS(8'sd3), .OVR(11), .AddrW(18)) i1 ();
  v86_ov                                                                                 i2 ();
endmodule
