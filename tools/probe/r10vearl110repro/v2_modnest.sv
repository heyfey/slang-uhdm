// r10vearl110 arm v2 -- THE genDepth BREAK RULE, attacked head on.
// genDepth110 walks VpiParent and BREAKS at module_inst/interface_inst/package/
// class_defn/program.  So a select inside a depth-1 generate of a CHILD module
// scores 1 even when that child is itself instantiated inside a generate scope
// of the parent -- the ELABORATED generate nesting there is 2, which g6 v7/v9
// measured as SYMBOLIC.  If Surelog's real axis is the elaborated depth rather
// than the per-instance depth, this is an AWAY.
package pv2;
  typedef struct packed { logic [31:0] fld; } c_t;
endpackage

// child with its OWN depth-1 generate
module v2_child #(parameter int unsigned NCH = 2) (
  input  pv2::c_t chan [NCH],
  output logic [31:0] oy
);
  localparam int unsigned SA = 9;
  localparam int unsigned SB = 3;
  logic [31:0] y1;
  for (genvar z = 0; z < NCH; z++) begin : ch_blk
    assign y1 = {26'b0, chan[z].fld[0+:(SA-SB)]};
  end
  assign oy = y1;
endmodule

// child with NO generate at all -- module scope, depth 0 by our rule
module v2_flat #(parameter int unsigned NCH = 2) (
  input  pv2::c_t chan [NCH],
  output logic [31:0] oy
);
  localparam int unsigned SA = 9;
  localparam int unsigned SB = 3;
  assign oy = {26'b0, chan[0].fld[0+:(SA-SB)]};
endmodule

module v2_modnest #(parameter int unsigned NCH = 2) (
  input  pv2::c_t chan [NCH],
  output logic [31:0] oz
);
  logic [31:0] r1, r2, r3, r4;
  // b1 -- child WITH a generate, instantiated inside a depth-1 generate.
  //       elaborated generate depth of the select = 2; our rule says 1.
  for (genvar g = 0; g < 1; g++) begin : out_blk
    v2_child #(.NCH(NCH)) u_c1 (.chan(chan), .oy(r1));
  end
  // b2 -- the SAME child instantiated at module scope (depth 1 either way)
  v2_child #(.NCH(NCH)) u_c2 (.chan(chan), .oy(r2));
  // b3 -- flat child inside a depth-1 generate: elaborated depth 1, ours 0
  for (genvar g = 0; g < 1; g++) begin : out_blk2
    v2_flat #(.NCH(NCH)) u_f1 (.chan(chan), .oy(r3));
  end
  // b4 -- the flat child at module scope (depth 0 either way)
  v2_flat #(.NCH(NCH)) u_f2 (.chan(chan), .oy(r4));
  assign oz = r1 ^ r2 ^ r3 ^ r4;
endmodule
