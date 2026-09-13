// v12 — the fence walk must STOP at a packed union: a struct whose member is a
// packed array of UNIONS, and a struct whose member is a union that itself
// carries a struct.  Golden assembles both.
package p;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } inner_t;
  typedef union packed { logic [15:0] w; inner_t s; } u_t;
  typedef struct packed { int unsigned n; u_t [1:0] ua; } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n  = 11;
    c.ua = 32'h1234_5678;
    return c;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output wire [31:0] o_n,
    output wire [31:0] o_ua
);
  assign o_n  = CFG.n;
  assign o_ua = CFG.ua;
endmodule
