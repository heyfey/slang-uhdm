// v11u74 v7 — LAW A shapes the implementer's grid does not carry, plus the
// CELL WHERE BOTH LAWS FIRE AT ONCE (a gen-local target with a module-body
// namesake whose Rhs is the folded member read).
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c;
    c.n = x;
    c.t = 8'hC3;
    return c;
  endfunction
  localparam cfg_t BUILT = build(64);
endpackage
module dut #(parameter p::cfg_t FB = p::BUILT)
  (output logic [31:0] o);
  localparam p::cfg_t LOC = p::build(128);   // a MODULE-level localparam base
  logic [31:0] both;                          // the namesake for the joint cell
  logic [31:0] t_loc;
  assign t_loc = LOC.n;                       // module-level twin of the base
  for (genvar i = 0; i < 2; i = i + 1) begin : gf
    localparam p::cfg_t GLOC = p::build(256); // a GEN-SCOPE localparam base
    logic [31:0] both;                        // BOTH laws fire on this cell
    wire  [31:0] netlhs;                      // gen-local NET target
    logic [31:0] gl_loc;
    logic [31:0] twice_a, twice_b;
    assign both    = FB.n;
    assign netlhs  = FB.n;
    assign gl_loc  = GLOC.n;
    assign twice_a = FB.t;
    assign twice_b = FB.t;                    // the same member read twice
  end
  assign both = 32'd1;
  assign o = gf[0].both ^ gf[1].both ^ gf[0].netlhs ^ gf[0].gl_loc
           ^ gf[0].twice_a ^ gf[0].twice_b ^ both ^ t_loc;
endmodule
