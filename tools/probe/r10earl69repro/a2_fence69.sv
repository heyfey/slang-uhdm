// r10earl69 arm a2 — THE FENCE.  Every bracket-group shape the rewrite must
// REFUSE to touch, plus the shapes it must take, on ONE golden.
package q69;
  parameter int QP = 5;
  parameter int QW = 4;
endpackage

typedef struct packed { logic [31:0] a; logic [31:0] b; } r69_t;

module f69 import q69::*; ();
  localparam int LQ = 5;
  localparam int LW = 4;
  r69_t  st [8];
  r69_t  st2[8][8];
  logic [7:0] idx [8];
  logic [7:0] o [64];
  logic       ob [64];
  logic [63:0] wide;

  function automatic int fn69(int x); return x + 1; endfunction

  for (genvar i = 0; i < 2; i++) begin : gf
    // TAKE: bare package parameter as an ips bound
    assign o[0]  = st[i].a[QP+:QW];
    // TAKE: bare LOCAL localparam as an ips bound
    assign o[1]  = st[i].a[LQ+:LW];
    // TAKE: bare parameter as a simple range bound
    assign o[2]  = st[i].a[QW:0];
    // REFUSE: an OPERATION bound keeps its spelling on BOTH sides
    assign o[3]  = st[i].a[QP-1+:QW];
    assign o[4]  = st[i].a[QP:QP-4];
    // REFUSE: a QUALIFIED read
    assign o[5]  = st[i].a[q69::QP+:QW];
    // REFUSE: a literal bound (nothing to fold)
    assign o[6]  = st[i].a[5+:4];
    // REFUSE: a function-call bound
    assign o[7]  = st[i].a[fn69(1)+:QW];
    // REFUSE: a SELECT bound
    assign o[8]  = st[i].a[idx[0]+:QW];
    // TAKE / REFUSE: the base index
    assign ob[0] = st[QP].a[0];        // bare param base index
    assign ob[1] = st[i].a[0];         // genvar base index (stays `i`)
    assign ob[2] = st[QP-3].a[0];      // operation base index
    // two-dimensional base select
    assign o[9]  = st2[QP][i].a[QP+:QW];
    // a var_select-shaped read
    assign o[10] = st2[i][QP].b[LQ+:LW];
    // a plain dotted read with no group at all
    assign o[11] = st[0].b;
    // an ips over a WHOLE-word member (no base select)
    assign o[12] = st[0].a[QP+:QW];
  end

  // module-body copies of the same shapes (no gen scope)
  assign o[13] = st[0].a[QP+:QW];
  assign o[14] = st[0].a[LQ+:LW];
  assign o[15] = st[0].a[QP-1+:QW];
endmodule
