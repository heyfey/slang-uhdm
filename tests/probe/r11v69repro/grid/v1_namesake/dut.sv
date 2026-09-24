// v11u69 v1 — THE NAMESAKE WIDTH DIVERGENCE.  `bindVariable` binds by NAME, so
// golden's `tps` comes from the MODULE-BODY namesake, not from the gen-local
// target the assignment really writes.  Every pair below gives the two a
// DIFFERENT width, which `g10_lhsbind` never did (both were 32 there).
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input  logic a_i,
   output logic [31:0] o_a, o_b, o_c);

  logic [7:0]  nw;     // module-body namesake, NARROW
  logic [63:0] ww;     // module-body namesake, WIDE
  logic [31:0] pl;     // module-body namesake, same width (control)

  if (1) begin : ga
    logic [31:0] nw;   // gen-local WIDE, namesake NARROW
    assign nw = CFG.n;
    assign o_a = nw;
  end

  if (1) begin : gb
    logic [7:0]  ww;   // gen-local NARROW, namesake WIDE
    assign ww = CFG.n;
    assign o_b = {24'd0, ww};
  end

  if (1) begin : gc
    logic [31:0] pl;   // CONTROL: same width both sides
    assign pl = CFG.n;
    assign o_c = pl;
  end

  assign nw = 8'd0;
  assign ww = 64'd0;
  assign pl = 32'd0;
endmodule
