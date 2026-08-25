// v93 adversarial arm V5 — class/program/bind homes, extra widths, chained reads.
package v5pkg;
  localparam int PW256 = 256;
  localparam v5_p31  = 31'(64'hFFFF_FFFF_FFFF_FFFF);
  localparam v5_p33  = 33'(64'hFFFF_FFFF_FFFF_FFFF);
  localparam v5_p63  = 63'(64'hFFFF_FFFF_FFFF_FFFF);
  localparam v5_p65  = 65'(64'hFFFF_FFFF_FFFF_FFFF);
  localparam v5_p127 = 127'(64'hFFFF_FFFF_FFFF_FFFF);
  localparam v5_p256 = 256'(64'hFFFF_FFFF_FFFF_FFFF);
  localparam v5_pp   = PW256'(64'hFFFF_FFFF_FFFF_FFFF);
  // chained parameter reads: does the masked value propagate?
  localparam v5_a    = 64'(64'd5);
  localparam v5_b    = v5_a;
  localparam v5_c    = v5_a + 64'd1;
  localparam v5_d    = 96'(v5_a);
endpackage

module v5_bindee (input logic clk);
  localparam logic [63:0] LBD = 64'(64'hFFFF_FFFF_FFFF_FFFF);
endmodule

module v5_bound (input logic clk);
  localparam logic [95:0] LBN = 96'(64'hFFFF_FFFF_FFFF_FFFF);
endmodule

program v5_prog;
  localparam logic [63:0] LPG = 64'(64'hFFFF_FFFF_FFFF_FFFF);
  initial $display(LPG);
endprogram

module v5_top (input logic clk, output logic [63:0] o);
  import v5pkg::*;
  v5_bindee u_bd (.clk(clk));
  assign o = {32'd0, v5_a[31:0]} ^ {32'd0, v5_b[31:0]} ^ {32'd0, v5_c[31:0]}
           ^ v5_d[63:0] ^ v5_p65[63:0] ^ v5_p256[63:0] ^ v5_pp[63:0]
           ^ {33'd0, v5_p31} ^ {31'd0, v5_p33} ^ {1'd0, v5_p63} ^ v5_p127[63:0];
endmodule
bind v5_bindee v5_bound u_bn (.clk(clk));
