// v85 adversarial arm A7 — the LITERAL FAMILY boundary: which spellings are
// size(-1) in Surelog and which are not.
module va7_lits85 #(parameter int W = 4) ();
  localparam logic [31:0] k01 = ~('h1  << W);
  localparam logic [31:0] k02 = ~('H1  << W);
  localparam logic [31:0] k03 = ~('d1  << W);
  localparam logic [31:0] k04 = ~('D1  << W);
  localparam logic [31:0] k05 = ~('o1  << W);
  localparam logic [31:0] k06 = ~('O1  << W);
  localparam logic [31:0] k07 = ~('b1  << W);
  localparam logic [31:0] k08 = ~('B1  << W);
  localparam logic [31:0] k09 = ~('b0  << W);
  localparam logic [31:0] k10 = ~('b11 << W);
  localparam logic [31:0] k11 = ~('b10 << W);
  localparam logic [31:0] k12 = ~('sh1 << W);
  localparam logic [31:0] k13 = ~('sb1 << W);
  localparam logic [31:0] k14 = ~('sd1 << W);
  localparam logic [31:0] k15 = ~('so1 << W);
  localparam logic [31:0] k16 = ~('SH1 << W);
  localparam logic [31:0] k17 = ~('hF  << W);
  localparam logic [31:0] k18 = ~('h 1 << W);
  localparam logic [31:0] k19 = ~(1    << W);
  localparam logic [31:0] k20 = ~(1'b1 << W);
  localparam logic [31:0] k21 = ~(32'd1 << W);
  localparam logic [31:0] k22 = ~('h1_0 << W);
  // right shifts
  localparam logic [31:0] k23 = ~('hff >> W);
  localparam logic [31:0] k24 = ~('hff >>> W);
  localparam logic [31:0] k25 = ~(8'hff >> W);
  localparam logic [31:0] k26 = ~('hff <<< W);
  // amount side is size(-1) (rule (1) is arg0 ONLY)
  localparam logic [31:0] k27 = ~(32'h1 << 'h2);
  localparam logic [31:0] k28 = ~(32'h1 << 'b1);
  // no shift at all
  localparam logic [31:0] k29 = ~('hff);
  localparam logic [31:0] k30 = ~('hff + 1);
  localparam logic [31:0] k31 = ~('hff * 2);
  localparam logic [31:0] k32 = 'hff;
  localparam logic [31:0] k33 = ~('hff & 'h0f);
endmodule
