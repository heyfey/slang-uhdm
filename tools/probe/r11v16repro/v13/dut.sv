// v13 — a packed array of packed structs written with a PLAIN CONSTANT (no
// nested assignment pattern), the shape the extended fence also declines.
package p;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } inner_t;
  typedef struct packed { int unsigned n; inner_t [1:0] arr; } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n   = 5;
    c.arr = 32'hAABB_CCDD;
    return c;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output wire [31:0] o_n
);
  assign o_n = CFG.n;
endmodule
