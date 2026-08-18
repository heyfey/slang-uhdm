// r10v67 verifier arm 5 — the REFUSAL edges.  A SHADOWING same-named
// localparam at distance 0 and distance 1 (slang must bind the inner one and
// the fold must refuse the outer); an X/Z-valued localparam; a REAL and a
// STRING localparam used elsewhere in the same block; a localparam declared
// in an UNNAMED generate block read one hop down; a localparam read one hop
// down through a NAMED BEGIN block (the earl47 F1 refusal); and a localparam
// whose declaring block is a gen-for over a MODULE parameter bound differently
// in two instances.
module v5child67 #(parameter int unsigned NW = 2) (input logic [15:0] a,
                                                   output logic [15:0] z);
  for (genvar g = 0; g < NW; g++) begin : eA
    localparam int unsigned K = g + 1;      // OUTER K
    localparam int unsigned Kok = g + 5;
    localparam real         Kr = 1.5;
    localparam string       Ks = "hi";
    if (1) begin : eB
      localparam int unsigned K = 7;        // INNER K shadows the outer
      logic sh, ok;
      assign sh = a[K];                     // must bind the INNER K (dist 0)
      assign ok = a[Kok];                   // one hop, must fold
      assign z[g] = sh ^ ok ^ (Kr > 1.0) ^ (Ks == "hi");
    end
    // an UNNAMED generate block one hop down
    if (1) begin
      logic ub;
      assign ub = a[Kok];
      assign z[8+g] = ub;
    end
  end
  // a localparam declared in an UNNAMED gen block, read one hop down
  if (1) begin
    localparam int unsigned Kun = 3;
    if (1) begin : uB
      logic ur;
      assign ur = a[Kun];
      assign z[15] = ur;
    end
  end
endmodule

module v5_edge67 (input logic [15:0] d, output logic [15:0] y);
  logic [15:0] z1, z2;
  v5child67 #(.NW(2)) u_a (.a(d), .z(z1));
  v5child67 #(.NW(3)) u_b (.a(d), .z(z2));
  assign y = z1 ^ z2;
endmodule
