// r10earl52 arm a2 — LITERAL SPELLING x {ternary, direct} into an `int`
// target.  Pins WHICH producer encodings reach adjustSize's signed-int arm,
// and whether the sign-extension the head shows is really "MSB of the WRITTEN
// literal width" and not "any nonzero value".
module a2_earl52 #(parameter bit C = 1'b0) ();
  // 1-bit binary, MSB set / clear  (the head's own shape)
  localparam int T_b1x = C ? 1'b0 : 1'b1;
  localparam int D_b1x =              1'b1;
  localparam int T_b0x = C ? 1'b1 : 1'b0;
  localparam int D_b0x =              1'b0;
  // 2-bit binary, MSB set / clear -> INT:-2 vs BIN:01?
  localparam int T_b10 = C ? 2'b00 : 2'b10;
  localparam int D_b10 =              2'b10;
  localparam int T_b01 = C ? 2'b00 : 2'b01;
  localparam int D_b01 =              2'b01;
  // 4-bit binary MSB set
  localparam int T_b4  = C ? 4'b0000 : 4'b1001;
  localparam int D_b4  =                4'b1001;
  // signed 1-bit binary
  localparam int T_sb1 = C ? 1'sb0 : 1'sb1;
  localparam int D_sb1 =              1'sb1;
  // unbased-unsized fills
  localparam int T_ub1 = C ? '0 : '1;
  localparam int D_ub1 =           '1;
  localparam int T_ub0 = C ? '1 : '0;
  localparam int D_ub0 =           '0;
  // bare decimal (unsized)
  localparam int T_dec = C ? 0 : 1;
  localparam int D_dec =          1;
  // sized decimal
  localparam int T_d8  = C ? 8'd0 : 8'd5;
  localparam int D_d8  =            8'd5;
  // hex, MSB set / clear
  localparam int T_h8  = C ? 4'h0 : 4'h8;
  localparam int D_h8  =            4'h8;
  localparam int T_hab = C ? 8'h00 : 8'hab;
  localparam int D_hab =             8'hab;
  localparam int T_h2  = C ? 4'h0 : 4'h2;
  localparam int D_h2  =            4'h2;
  // octal
  localparam int T_o3  = C ? 3'o0 : 3'o7;
  localparam int D_o3  =            3'o7;
  // a WIDER-than-target source (33 bits into int)
  localparam int T_w33 = C ? 33'd0 : 33'h1_0000_0001;
  localparam int D_w33 =             33'h1_0000_0001;
  // an OPERATION inside the taken branch (not a bare literal)
  localparam int T_op  = C ? 1'b0 : (1'b1 | 1'b0);
  localparam int D_op  =            (1'b1 | 1'b0);
  // a PARAMETER reference inside the taken branch
  localparam bit SRCB = 1'b1;
  localparam int T_pr  = C ? 1'b0 : SRCB;
  localparam int D_pr  =            SRCB;
  // the corpus's SECOND row: 4'h2 / 4'h0 into int (rv_core_ibex.sv:68)
  localparam int T_fd  = C ? 4'h2 : 4'h0;
  localparam int D_fd  =            4'h0;
endmodule
