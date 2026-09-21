// r11v75 xf — LAW C's BASE REACHED ACROSS BLOCKS.  `asmRefFamilyBase` accepts a
// HierarchicalValue, so a localparam declared in ANOTHER generate block is a
// gen-scope base too and takes the new road.  `genScopeParamObj75` is keyed on
// the ParameterSymbol, so the drain reads the OTHER block's parameter object.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
endpackage

module dut (output logic [31:0] o);
  if (1) begin : A1
    localparam p::cfg_t A_LOC = p::build(320);
    logic [31:0] a_own;  assign a_own = A_LOC.n;     // own block: the control
  end
  if (1) begin : A2
    logic [31:0] a_cross; assign a_cross = A1.A_LOC.n;   // ACROSS blocks
    logic [7:0]  a_ct;    assign a_ct    = A1.A_LOC.t;
  end
  for (genvar i = 0; i < 2; i = i + 1) begin : A3
    localparam p::cfg_t L_LOC = p::build(400 + i);
    logic [31:0] a_it; assign a_it = L_LOC.n;        // per iteration
  end
  if (1) begin : A4
    logic [31:0] a_idx; assign a_idx = A3[1].L_LOC.n;  // another ITERATION's base
  end
  assign o = A1.a_own ^ A2.a_cross ^ {24'd0, A2.a_ct} ^ A3[0].a_it ^ A3[1].a_it
           ^ A4.a_idx;
endmodule
