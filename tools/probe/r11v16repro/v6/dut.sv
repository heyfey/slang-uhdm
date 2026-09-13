// v6 — Lhs WIDTH matrix around the two adjustSize branches, with the member
// read under narrow / exact / wide bound targets and unbound ones.
package p;
  typedef struct packed { int unsigned n; logic [63:0] wide; byte b; } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n    = 32'hDEADBEEF;
    c.wide = 64'h0123456789ABCDEF;
    c.b    = 8'h5A;
    return c;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output wire [7:0]  o_n8,
    output wire [31:0] o_n32,
    output wire [63:0] o_n64,
    output wire [7:0]  o_w8,
    output wire [63:0] o_w64,
    output wire [31:0] o_b32,
    output wire [31:0] o_ps,
    output wire [15:0] o_ca, o_cb
);
  assign o_n8  = CFG.n;
  assign o_n32 = CFG.n;
  assign o_n64 = CFG.n;
  assign o_w8  = CFG.wide;
  assign o_w64 = CFG.wide;
  assign o_b32 = CFG.b;
  assign o_ps[15:0] = CFG.n;
  assign {o_ca, o_cb} = CFG.n;
endmodule
