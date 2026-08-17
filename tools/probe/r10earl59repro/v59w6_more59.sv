// r10earl59 VERIFIER arm W6 — the MISS direction (we fold, Surelog does not),
// exotic net types, and a packed-array whole-ref LHS.
module w6sub (
  input        [3:0] din,
  output       [3:0] o
);
  wire  [3:0] mn_src;
  logic       me;
  wire  [3:0] mn_litop;      // Rhs is an operation over LITERALS ONLY
  wire  [3:0] mn_ternc;      // ternary with a CONSTANT condition
  wire  [3:0] mn_bitsop;     // $bits-only operation
  uwire [3:0] mn_uwire;      // uwire net
  tri   [3:0] mn_tri;        // tri net
  wand  [3:0] mn_wand;       // wand net
  wire  [1:0][3:0] mn_parr;  // PACKED ARRAY net, whole-ref LHS
  assign mn_src = din;
  assign me     = din[0];
  assign o      = mn_litop ^ mn_ternc ^ mn_bitsop ^ mn_uwire ^ mn_tri ^ mn_wand;

  if (1) begin : g_a
    if (1) begin : g_b
      wire [3:0] lb;
      assign lb        = mn_src;
      assign mn_litop  = 4'h1 | 4'h2;
      assign mn_ternc  = 1'b1 ? 4'h3 : 4'h4;
      assign mn_bitsop = $bits(lb) + 1;
      assign mn_uwire  = lb | mn_src;
      assign mn_tri    = lb | mn_src;
      assign mn_wand   = lb | mn_src;
      assign mn_parr   = {lb, lb} | 8'h0;
    end
  end
endmodule

module a1;
  wire [3:0] din, o1;
  w6sub u_sub (.din(din), .o(o1));
endmodule
