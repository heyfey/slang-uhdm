// v2 — the Lhs SHAPES the shared-slot clone has to reproduce: a typedef'd net,
// a plain variable, an output port, a net with its own declared typespec.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  typedef logic [31:0] word_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n    = 3;
    c.base = 64'h1000;
    return c;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output wire [31:0] o_port,
    output p::word_t   o_tport
);
  p::word_t  w_typedef;
  wire [31:0] w_plain;
  logic [31:0] v_var;
  assign o_port    = CFG.n;
  assign o_tport   = CFG.n;
  assign w_typedef = CFG.n;
  assign w_plain   = CFG.n;
  assign v_var     = CFG.n;
endmodule
