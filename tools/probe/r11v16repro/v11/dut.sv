// v11 — the base reached through a CHAIN of bare parameter references, and the
// same struct type carried by TWO parameters with different values read side
// by side.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build(int unsigned v);
    cfg_t c;
    c.n    = v;
    c.base = 64'h1000;
    return c;
  endfunction
endpackage

module dut #(
    parameter p::cfg_t CFG = p::build(3),
    parameter p::cfg_t CFG2 = p::build(9)
) (
    output wire [31:0] o_a, o_b, o_c
);
  localparam p::cfg_t ALIAS = CFG;
  localparam p::cfg_t ALIAS2 = ALIAS;
  assign o_a = ALIAS.n;
  assign o_b = ALIAS2.n;
  assign o_c = CFG2.n;
endmodule
