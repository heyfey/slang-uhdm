// r11v75 xh — IS THE FOLD KEYED ON THE SCOPE RELATION OR ON THE REFERENCE
// FORM?  `xf_crossblk` shows golden declines a SIBLING block's base; this arm
// asks the ANCESTOR reached by a HIERARCHICAL path, and the ancestor reached
// by a SIMPLE name, side by side.
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
      logic [31:0] b_simple; assign b_simple = B_LOC.n;      // ancestor, SIMPLE name
      logic [31:0] b_path;   assign b_path   = B1.B_LOC.n;   // ancestor, HIER path
      logic [31:0] b_mod;    assign b_mod    = M_LOC.n;      // module base, simple
      logic [31:0] b_modp;   assign b_modp   = dut.M_LOC.n;  // module base, HIER path
      localparam p::cfg_t C_LOC = p::build(704);
      logic [31:0] b_self;   assign b_self   = C_LOC.n;      // this scope's own base
    end
  end
  assign o = B1.B2.b_simple ^ B1.B2.b_path ^ B1.B2.b_mod ^ B1.B2.b_modp
           ^ B1.B2.b_self;
endmodule
