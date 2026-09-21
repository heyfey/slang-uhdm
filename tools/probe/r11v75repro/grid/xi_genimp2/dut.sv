// r11v75 xi — THE IMPORT HOME IN A SCOPE THAT IS NOT THE HOLDER'S SCOPE.  The
// MODULE imports the package (so our hoist keys the object in netMap) AND the
// enclosing generate block imports it too.  The one searchable scope out is the
// GENERATE BLOCK, whose import items now resolve the name onto the MODULE's
// object.  `xg_genimp` measured that a gen-block import alone is not a home in
// golden; does golden bind here?
package pg;
  logic [15:0] g_ns;
  logic [15:0] k_ns;
endpackage

module dut (output logic [31:0] o);
  import pg::*;                       // MODULE-level import: the holder exists
  for (genvar i = 0; i < 1; i = i + 1) begin : G1
    import pg::*;                     // the enclosing block imports it too
    logic [31:0] k_ns;  assign k_ns = 32'd9;   // target ONE scope out: control
    if (1) begin : G2
      logic [31:0] g_ns;  assign g_ns = 32'd1; // one scope out = G1 (block import)
    end
  end
  assign o = G1[0].G2.g_ns ^ G1[0].k_ns;
endmodule
