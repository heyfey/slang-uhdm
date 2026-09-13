// v10 — a HIERARCHICAL member read from a child: `assign o = top.CFG.n;`.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n    = 3;
    c.base = 64'h1000;
    return c;
  endfunction
endpackage

module kid (output wire [31:0] o);
  assign o = dut.CFG.n;
endmodule

module dut (output wire [31:0] o_k, o_l);
  localparam p::cfg_t CFG = p::build();
  assign o_l = CFG.n;
  kid u1 (o_k);
endmodule
