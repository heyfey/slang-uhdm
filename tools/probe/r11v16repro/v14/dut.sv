// v14 — further DELAY and STRENGTH shapes on the folding continuous assignment:
// a min:typ:max delay, a rise/fall pair, a parameter-valued delay, and the
// pull/highz strength pair.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n    = 3;
    c.base = 64'h1000;
    return c;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build(), parameter int D = 7) (
    output wire [31:0] o_mtm,
    output wire [31:0] o_rf,
    output wire [31:0] o_pd,
    output wire [31:0] o_pull
);
  assign #(1:2:3) o_mtm = CFG.n;
  assign #(2, 4)  o_rf  = CFG.n;
  assign #D       o_pd  = CFG.n;
  assign (pull0, highz1) o_pull = CFG.n;
endmodule
