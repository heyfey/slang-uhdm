// v8 — a comma-list continuous assign, a repeated member read, the whole read
// and a member read side by side in ONE statement list.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n    = 6;
    c.base = 64'h3000;
    return c;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output wire [31:0] o_a, o_b,
    output wire [63:0] o_c,
    output wire [31:0] o_d
);
  assign o_a = CFG.n, o_b = CFG.n;
  assign o_c = CFG.base;
  assign o_d = CFG.n;
endmodule
