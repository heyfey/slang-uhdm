// v9 — a PARTIALLY DEFINED assembly: a member the builder never writes, so its
// digits are x.  The producer refuses a slice that is not fully defined.
package p;
  typedef struct packed { int unsigned n; logic [15:0] never_set; logic [7:0] t; } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n = 3;
    c.t = 8'hA5;
    return c;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output wire [31:0] o_n,
    output wire [15:0] o_x,
    output wire [7:0]  o_t
);
  assign o_n = CFG.n;
  assign o_x = CFG.never_set;
  assign o_t = CFG.t;
endmodule
