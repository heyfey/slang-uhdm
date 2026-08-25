// v93 adversarial arm V1 — contexts the implementer's table does not name.
package v1pkg;
  parameter int PW64  = 64;
  parameter int PW96  = 96;
  parameter int PW128 = 128;
  parameter logic [63:0] PKGP = PW64'(64'hFFFF_FFFF_FFFF_FFFF);
endpackage

module v1_child #(parameter int W = 64) (input logic clk, output logic [63:0] o);
  localparam logic [W-1:0] L_ovr = W'(64'hFFFF_FFFF_FFFF_FFFF);
  assign o = L_ovr[63:0] ^ {64{clk}};
endmodule

interface v1_if #(parameter int W = 96) ();
  localparam logic [W-1:0] L_iface = W'(64'hFFFF_FFFF_FFFF_FFFF);
  logic [63:0] w;
  assign w = L_iface[63:0];
endinterface

module v1_defp #(parameter int DW = 32) (input logic clk, output logic [63:0] o);
  localparam logic [DW-1:0] L_dw = DW'(64'hFFFF_FFFF_FFFF_FFFF);
  parameter logic [63:0] PV = 64'd7;
  assign o = L_dw[31:0] ^ PV ^ {64{clk}};
endmodule

module v1_top (input logic clk, output logic [63:0] o);
  import v1pkg::*;
  localparam logic [63:0] L_pkgw   = PW64'(64'hFFFF_FFFF_FFFF_FFFF);
  localparam logic [95:0] L_pkgw96 = PW96'(64'hFFFF_FFFF_FFFF_FFFF);
  localparam logic [63:0] L_imp    = PKGP;
  localparam logic [63:0] L_bits   = ($bits(L_pkgw))'(64'hFFFF_FFFF_FFFF_FFFF);
  localparam logic [63:0] L_bitsop = 64'($bits(L_pkgw96));
  localparam logic [63:0] L_str    = 64'("ab");
  localparam logic [63:0] L_uns    = 64'('1);
  localparam logic [63:0] L_enumw  = 64'(2);
  localparam logic [63:0] L_call   = 64'($clog2(129));
  logic [63:0] w_dim;
  logic [64'(4)-1:0] w_bnd;
  v1_child #(.W(64))  u64  (.clk(clk), .o());
  v1_child #(.W(96))  u96  (.clk(clk), .o());
  v1_child #(.W(128)) u128 (.clk(clk), .o());
  v1_defp  u_dp (.clk(clk), .o());
  defparam u_dp.DW = 64;
  v1_if #(.W(96)) u_if ();
  assign w_dim = {60'd0, w_bnd};
  assign o = L_pkgw ^ L_imp ^ L_bits ^ L_bitsop ^ L_str ^ L_uns ^ L_enumw ^ L_call ^ w_dim ^ L_pkgw96[63:0];
endmodule
