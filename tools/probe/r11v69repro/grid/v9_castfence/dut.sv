// v11u69 v9 — THE PASS-54 CAST FENCE AND THE W1 CHAINS, re-homed into a
// generate block.  Every row has a module-level twin.
package p;
  typedef struct packed { int unsigned n; logic [7:0] w; } cfg_t;
  localparam cfg_t LIT  = '{n: 5, w: 8'd6};
  localparam cfg_t LIT2 = LIT;                 // W1: one more hop
  typedef struct packed { cfg_t c; int unsigned z; } out_t;
  localparam out_t OL = '{c: LIT, z: 9};       // W2 through a named reference
endpackage

module dut #(parameter p::cfg_t CFG  = p::LIT,
             parameter p::cfg_t CFG2 = p::LIT2,
             parameter p::out_t OC   = p::OL,
             parameter p::cfg_t NOD)             // NO default: overridden only
  (input  logic a_i,
   output logic [31:0] t_hop, g_hop,
   output logic [31:0] t_w2,  g_w2,
   output logic [31:0] t_cast, g_cast,
   output logic [31:0] t_nod, g_nod);

  assign t_hop  = CFG2.n;
  assign t_w2   = OC.c.n;
  assign t_cast = int'(CFG.n);
  assign t_nod  = NOD.n;

  if (1) begin : gk
    assign g_hop  = CFG2.n;
    assign g_w2   = OC.c.n;
    assign g_cast = int'(CFG.n);
    assign g_nod  = NOD.n;
  end
endmodule

module top (input logic a_i, output logic [31:0] a,b,c,d,e,f,g,h);
  dut #(.NOD(p::cfg_t'('{n: 77, w: 8'd1}))) u (.a_i(a_i),
    .t_hop(a), .g_hop(b), .t_w2(c), .g_w2(d),
    .t_cast(e), .g_cast(f), .t_nod(g), .g_nod(h));
endmodule
