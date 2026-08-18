// r10rgg18 grid B — the SAME MSB-set fold across 1..3 UNROLLINGS x 1..3
// INSTANCES of the containing module (the Rggen head's real shape: seven
// instances of rggen_register_common with seven different OFFSET_ADDRESS
// values), plus the NEGATIVE-SIBLING interaction the `negSib9` arm owns.
// Written as .v on purpose: the boundary and the grid must both cross the
// language-flag axis.
module b1_leaf #(parameter WIDTH = 7, parameter [6:0] BASE = 7'h40,
                 parameter N = 1) ();
  genvar g;
  generate
    for (g = 0; g < N; g = g + 1) begin : gs
      // U: the head's shape -- a cast SEALS the arithmetic, MSB-set result.
      localparam [6:0] U = BASE + 7'(4 * g);
      // S: one instance NEGATIVE, another MSB-set POSITIVE, same declaration
      // (`-` mints signed, so this is the negSib9/structural arm).
      localparam [6:0] S = 0 - 1 + 65 * g;
      // T: a SIGNED declared type carrying MSB-set unsigned bits.
      localparam signed [6:0] T = BASE + 7'(4 * g);
      if (U == S && T == 0) begin : gu
        wire w;
      end
    end
  endgenerate
endmodule

module b1_rgg18;
  b1_leaf #(.BASE(7'h40), .N(1)) i1 ();
  b1_leaf #(.BASE(7'h44), .N(2)) i2 ();
  b1_leaf #(.BASE(7'h48), .N(3)) i3 ();
endmodule
