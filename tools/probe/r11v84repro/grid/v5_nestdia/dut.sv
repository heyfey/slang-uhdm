// v11u84 v5 — THE NESTED DIAMOND (the multiset below the top level).
// t3_shapes measured the TOP-level diamond (two import items of the importer
// itself), which our `seen9` set does NOT dedupe because each item starts its
// own recursion.  This arm puts the diamond ONE HOP DOWN: nd3 imports nd2,
// and nd2 imports nd1 twice over two routes.  Golden's producer pushes
// POINTERS per item and dedupes nothing, so nd2's vector should carry nd1's
// entries twice and nd3's should carry them twice again.
package nd1;
  wire  [7:0] d_net;
  logic [7:0] d_var = 8'd9;
endpackage

package nd1b;
  import nd1::*;                 // route B
  wire  [7:0] db_net;
endpackage

package nd2;
  import nd1::*;                 // route A: direct
  import nd1b::*;                // route B: transitive — the same nd1 entries
  logic [7:0] d2_own;
endpackage

package nd3;
  import nd2::*;                 // one hop above the diamond
  wire  [7:0] d3_own;
endpackage

module dut (output logic [31:0] o);
  import nd3::*;
  assign o = {24'd0, d3_own};
endmodule
