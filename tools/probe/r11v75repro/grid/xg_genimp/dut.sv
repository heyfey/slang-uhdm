// r11v75 xg — LAW B WHERE THE IMPORT IS IN THE ONE SCOPE THE WALK SEARCHES AND
// THAT SCOPE IS A GENERATE BLOCK.  `nsImportHome75` reads the import items of
// whatever scope it is handed, so a package import written INSIDE the enclosing
// generate block is a home too — and the object it binds is the MODULE-level
// hoist, whose name is `work@dut.<n>` and not the block's.
package pg;
  logic [15:0] g_ns;
  logic [15:0] h_ns;
endpackage

module dut (output logic [31:0] o);
  for (genvar i = 0; i < 1; i = i + 1) begin : G1
    import pg::*;                       // WILDCARD import inside the gen block
    import pg::h_ns;                    // EXPLICIT import inside the gen block
    if (1) begin : G2
      logic [31:0] g_ns;  assign g_ns = 32'd1;
      logic [31:0] h_ns;  assign h_ns = 32'd2;
    end
  end
  assign o = G1[0].G2.g_ns ^ G1[0].G2.h_ns;
endmodule
