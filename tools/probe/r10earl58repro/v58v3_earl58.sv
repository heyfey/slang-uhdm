// v58 VERIFIER arm V3 — GENERATE KINDS, DISTANCES 0/1/2/3, SHADOWING, GENVARS,
// and the § elseArmFirstItemReplaces48 COLLAPSE (a path-strip mis-bind trap).
module v3_earl58 (input logic clk, input logic [63:0] v, output logic [63:0] o);
  localparam int unsigned MP = 3;

  // --- for-generate body -> nested named block (d1 across the loop body)
  for (genvar gi = 0; gi < 2; gi++) begin : fg
    localparam int unsigned FW = gi + 5;
    if (1) begin : fgi
      logic [63:0] r, rg;
      always_ff @(posedge clk) r  <= v[FW-2:0];   // d1 localparam
      always_ff @(posedge clk) rg <= v[gi+1:0];   // GENVAR at d1 -- must NOT fold
    end
  end

  // --- case-generate
  case (MP)
    3: begin : cg
      localparam int unsigned CW = 7;
      if (1) begin : cgi
        logic [63:0] r; always_ff @(posedge clk) r <= v[CW-2:0];
      end
    end
    default: begin : cgd end
  endcase

  // --- UNNAMED parent, named child
  if (1) begin
    localparam int unsigned UW = 9;
    if (1) begin : ui
      logic [63:0] r; always_ff @(posedge clk) r <= v[UW-2:0];
    end
  end

  // --- named parent, UNNAMED child
  if (1) begin : np
    localparam int unsigned NW = 11;
    if (1) begin
      logic [63:0] r; always_ff @(posedge clk) r <= v[NW-2:0];
    end
  end

  // --- d0 / d1 / d2 / d3 of ONE parameter
  if (1) begin : d_a
    localparam int unsigned DA = 13;
    logic [63:0] r0; always_ff @(posedge clk) r0 <= v[DA-2:0];      // d0
    if (1) begin : d_b
      logic [63:0] r1; always_ff @(posedge clk) r1 <= v[DA-2:0];    // d1
      if (1) begin : d_c
        logic [63:0] r2; always_ff @(posedge clk) r2 <= v[DA-2:0];  // d2
        if (1) begin : d_d
          logic [63:0] r3; always_ff @(posedge clk) r3 <= v[DA-2:0];// d3
        end
      end
    end
  end

  // --- SHADOWING: same name at two nesting levels
  if (1) begin : s_a
    localparam int unsigned SW = 20;
    if (1) begin : s_b
      localparam int unsigned SW = 30;
      logic [63:0] rs; always_ff @(posedge clk) rs <= v[SW-2:0];      // inner, d0
      if (1) begin : s_c
        logic [63:0] rs2; always_ff @(posedge clk) rs2 <= v[SW-2:0];  // s_b's SW, d1
      end
    end
  end

  // --- ELSE-ARM COLLAPSE with a SHADOWED name (path-strip mis-bind trap):
  //     the plain else arm is REPLACED by m_c, so m_c is EMITTED at m_a.m_c
  //     while its SCOPE-TREE parent is the arm, whose MW is 60, not 50.
  if (1) begin : m_a
    localparam int unsigned MW = 50;
    if (0) begin : mx
      logic [63:0] dummy;
    end
    else begin
      localparam int unsigned MW = 60;
      if (1) begin : m_c
        logic [63:0] r; always_ff @(posedge clk) r <= v[MW-2:0];
      end
    end
  end

  assign o = v;
endmodule
