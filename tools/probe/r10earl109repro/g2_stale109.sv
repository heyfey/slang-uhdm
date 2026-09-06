// r10earl109 arm g2 -- THE STALE-SCOPE HALF, reproduced.
//
// The corpus head shows its 64-bit face only because the module that declares
// the port INSTANTIATES ANOTHER MODULE (usbdev_usbif instantiates
// usbdev_linkstate at :342).  `currentScope` is assigned ONLY in
// emitModuleDef / emitModuleDefPorts, never inside emitInstance (RESUME
// section 9), so the child's def-encounter leaves it on the CHILD's body, and
// the parent instance's ELAB PORT typespecs -- built AFTER its children --
// fold their bounds in that foreign scope.  The ELAB NETs of the same signals
// are built BEFORE the children and still see the right scope, which is why
// only the port copy is wrong.
// MEASUREMENT ONLY.
module g2_leafC109 (
  input  logic a_i,
  output logic b_o
);
  assign b_o = ~a_i;
endmodule

module g2_pktA109 #(
  parameter  int MaxPktSizeByte = 64,
  parameter  int NEndpoints     = 12,
  localparam int PktW           = $clog2(MaxPktSizeByte)   // int, 32-bit, 6
) (
  input  logic                  clk_i,
  input  logic [PktW:0]         in_size_i,    // BARE int param  -- THE HEAD
  input  logic [NEndpoints-1:0] in_stall_i,   // expression      -- 64 both
  output logic [3:0]            ep_o,         // literal         -- 64 both
  output logic                  q_o
);
  logic [PktW:0] loc_v;                       // a VAR with the same bound
  wire  [PktW:0] loc_n = loc_v;               // a NET with the same bound
  logic          leaf_b;
  // THE STALE-SCOPE MAKER: a child def encountered inside this instance's walk.
  g2_leafC109 u_leaf (.a_i(clk_i), .b_o(leaf_b));
  assign loc_v = in_size_i;
  assign ep_o  = 4'd0;
  assign q_o   = clk_i & loc_n[0] & in_stall_i[0] & leaf_b;
endmodule

module g2_stale109;
  localparam int MaxPktSizeByte = 64;
  localparam int NEndpoints     = 12;
  logic        clk, q;
  logic [6:0]  sz;
  logic [11:0] st;
  logic [3:0]  ep;
  g2_pktA109 #(.MaxPktSizeByte(MaxPktSizeByte), .NEndpoints(NEndpoints)) u_a (
    .clk_i(clk), .in_size_i(sz), .in_stall_i(st), .ep_o(ep), .q_o(q));
endmodule
