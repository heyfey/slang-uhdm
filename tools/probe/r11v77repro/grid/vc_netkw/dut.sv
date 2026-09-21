// v11u77 vc -- LAW A face: the net keywords pkgNetKeywordVpi77 maps that no
// landed arm measured (uwire, tri1, triand, trior), plus a package net declared SIGNED.
package pw;
  uwire  [7:0] k_uwire;
  tri1   [7:0] k_tri1;
  triand [7:0] k_triand;
  trior  [7:0] k_trior;
  wire signed [7:0] k_signed;
endpackage

module dut (output logic [31:0] o);
  import pw::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] k_uwire;  assign k_uwire  = 32'd1;
    logic [31:0] k_tri1;   assign k_tri1   = 32'd2;
    logic [31:0] k_triand; assign k_triand = 32'd3;
    logic [31:0] k_trior;  assign k_trior  = 32'd4;
    logic [31:0] k_signed; assign k_signed = 32'd6;
  end
  assign o = gv[0].k_uwire ^ gv[0].k_tri1 ^ gv[0].k_triand ^ gv[0].k_trior
           ^ gv[0].k_signed;
endmodule
