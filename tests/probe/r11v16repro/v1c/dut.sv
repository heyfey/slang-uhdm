package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n    = 3;
    c.base = 64'h1000;
    return c;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output wire [31:0] o_str
);
  assign (supply0, supply1) o_str = CFG.n;
endmodule
