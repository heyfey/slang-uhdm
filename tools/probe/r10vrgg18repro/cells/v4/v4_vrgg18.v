// r10vrgg18 grid V4 — the .v arm: overridden module parameters x unrollings,
// with the overflow and negative-divide rows repeated across instances.
module v4_leaf #(parameter [7:0] B = 8'hC0, parameter N = 2) ();
  genvar g;
  generate
    for (g = 0; g < N; g = g + 1) begin : gs
      localparam [7:0]  UU = B + 8'(g);
      localparam [7:0]  DV = (8'd0 - 8'd8) / 8'd2;
      localparam [63:0] OV = 64'hFFFFFFFFFFFFFFFF + 64'd1 + 64'(g);
      localparam [7:0]  NG = 0 - 8'd64 + g;
      if (UU == DV && OV == 0 && NG == 0) begin : gu
        wire w;
      end
    end
  endgenerate
endmodule

module v4_vrgg18;
  v4_leaf #(.B(8'hC0), .N(2)) i1 ();
  v4_leaf #(.B(8'h40), .N(3)) i2 ();
endmodule
