// v58 VERIFIER arm V5 — the FOR-STATEMENT discriminator, and the else-arm
// COLLAPSE with the if-generate first (the real § elseArmFirstItemReplaces48
// path-strip trap).
module v5_earl58 (input logic clk, input logic en, input logic [63:0] v,
                  output logic [63:0] o);
  if (1) begin : g1
    localparam int unsigned L = 6;
    if (1) begin : g2
      integer k2;
      logic [63:0] r_fordecl, r_fornodecl, r_foreach, r_do, r_forever, r_blk,
                   r_nested, r_case2;
      logic [63:0] arr [0:3];
      always @(posedge clk) for (int k = 0; k < 2; k++) r_fordecl <= v[L-2:0];
      always @(posedge clk) for (k2 = 0; k2 < 2; k2++) r_fornodecl <= v[L-2:0];
      always @(posedge clk) foreach (arr[i]) r_foreach <= v[L-2:0];
      always @(posedge clk) do r_do <= v[L-2:0]; while (en);
      always @(posedge clk) forever r_forever <= v[L-2:0];
      always @(posedge clk) begin : bn
        int k3;
        r_blk <= v[L-2:0];
      end
      always @(posedge clk) begin
        if (en) begin
          for (int k = 0; k < 2; k++) begin
            r_nested <= v[L-2:0];
          end
        end
      end
      assign o = r_fordecl ^ r_fornodecl ^ r_foreach ^ r_do ^ r_forever ^
                 r_blk ^ r_nested;
    end
  end
  // --- REAL else-arm collapse: the arm's FIRST item is an if-generate.
  if (1) begin : m_a
    localparam int unsigned MW = 50;
    if (0) begin : mx
      logic [63:0] dummy;
    end
    else begin
      if (1) begin : m_c
        logic [63:0] r; always_ff @(posedge clk) r <= v[MW-2:0];
      end
      localparam int unsigned MW2 = 60;
    end
  end
endmodule
