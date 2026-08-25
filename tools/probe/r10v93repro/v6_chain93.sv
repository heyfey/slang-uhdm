// v93 adversarial arm V6 — mixed cast chains, signed-positive wide values,
// and "already right" controls that must stay right.
module v6_top (output logic [63:0] o);
  localparam logic [63:0] AO = 64'hFFFF_FFFF_FFFF_FFFF;
  // mixed chains: a keyword cast inside / outside a size cast
  localparam logic [95:0] m_96_int   = 96'(int'(AO));
  localparam logic [95:0] m_96_lint  = 96'(longint'(AO));
  localparam logic [95:0] m_96_bit   = 96'(bit'(AO));
  localparam logic [63:0] m_int_96   = int'(96'(AO));
  localparam logic [63:0] m_lint_96  = longint'(96'(AO));
  localparam logic [95:0] m_96_par   = 96'((64'(AO)));
  localparam logic [95:0] m_96_96    = 96'(96'(AO));
  localparam logic [127:0] m_128_65  = 128'(65'(AO));
  localparam logic [95:0] m_96_65_64 = 96'(65'(64'(AO)));
  // signed positive wide
  localparam logic signed [63:0] s_wide = 96'(64'h1000_0000_0000_0005);
  localparam logic signed [63:0] s_neg  = 96'(-64'sd3);
  // controls that are ALREADY RIGHT in pristine (mask is a no-op)
  localparam logic [63:0] r_64_0  = 64'(64'd0);
  localparam logic [95:0] r_96_7  = 96'(64'd7);
  localparam logic [64:0] r_65_1  = 65'(64'd1);
  localparam logic [126:0] r_127_9 = 127'(64'd9);
  localparam logic [31:0] r_32_5  = 32'(64'd5);
  localparam logic [62:0] r_63_5  = 63'(64'd5);
  assign o = m_96_int[63:0]^m_96_lint[63:0]^m_96_bit[63:0]^m_int_96^m_lint_96
           ^ m_96_par[63:0]^m_96_96[63:0]^m_128_65[63:0]^m_96_65_64[63:0]
           ^ s_wide^s_neg^r_64_0^r_96_7[63:0]^r_65_1[63:0]^r_127_9[63:0]
           ^ {32'd0,r_32_5} ^ {1'd0,r_63_5};
endmodule
