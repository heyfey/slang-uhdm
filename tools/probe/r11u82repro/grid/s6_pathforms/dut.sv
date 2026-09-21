// r11u82 s6 -- LAW A, the remaining written FORMS: a path from module level
// into a GENERATE scope, an INDEXED generate path, a two-component path, and
// the simple-name controls beside each.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
endpackage

module dut (output logic [31:0] o);
  localparam p::cfg_t M_LOC = p::build(600);
  if (1) begin : B1
    localparam p::cfg_t B_LOC = p::build(640);
    if (1) begin : B2
      localparam p::cfg_t D_LOC = p::build(672);
    end
  end
  for (genvar i = 0; i < 2; i = i + 1) begin : A1
    localparam p::cfg_t L_LOC = p::build(704 + i * 8);
  end
  logic [31:0] t_gen;  assign t_gen  = B1.B_LOC.n;      // module level -> gen block
  logic [31:0] t_deep; assign t_deep = B1.B2.D_LOC.n;   // two components
  logic [31:0] t_idx;  assign t_idx  = A1[1].L_LOC.n;   // indexed generate path
  logic [31:0] t_own;  assign t_own  = M_LOC.n;         // simple-name control
  assign o = t_gen ^ t_deep ^ t_idx ^ t_own;
endmodule
