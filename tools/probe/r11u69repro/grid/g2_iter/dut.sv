// r11u69 g2 — ITERATIONS.  A gen-for with THREE iterations: does golden mint a
// PER-ITERATION clone of the substituted constant, and does a value that
// DEPENDS ON THE GENVAR (an unpacked-array parameter read `AP[k]`, and a
// per-iteration member pick) get a per-iteration value?
package p;
  typedef struct packed { int unsigned n; int unsigned m; } cfg_t;
  localparam cfg_t LIT = '{n: 3, m: 7};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input  logic        a_i,
   output logic [31:0] o_same [0:2],
   output logic [31:0] o_gv   [0:2]);

  // The SAME value in every iteration — three cont_assigns, one source literal.
  for (genvar k = 0; k < 3; k++) begin : gsame
    assign o_same[k] = CFG.n;
  end

  // The member PICKED depends on the genvar, so the iterations do not share a
  // source object.
  for (genvar k = 0; k < 3; k++) begin : ggv
    if (k == 0) begin : a0
      assign o_gv[k] = CFG.n;
    end else begin : a1
      assign o_gv[k] = CFG.m;
    end
  end
endmodule
