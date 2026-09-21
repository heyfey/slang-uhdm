// r11u75 g5 — LAW C's SIZE RULE, which `g3_lpbase` leaves untested.  Every
// `g3` fold cell has `lhsw=0` (no namesake, so `bindVariable` binds nothing
// and the member's own width stands); `adjustSize`'s int/logic branches only
// run when the width walk DOES answer.  Here every target has a module-body
// namesake, so the walk answers, and the namesake's width is varied against
// the member kind — the same question `a2_fbwidths` asked for a MODULE base,
// asked again for a base declared in the generate scope.
package p;
  typedef struct packed {
    int unsigned n;      // 32, unsigned int member
    logic [39:0] w;      // 40, logic member
    byte         b;      // 8
  } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c;
    c.n = x;
    c.w = 40'h00C3A50F17;
    c.b = 8'h5B;
    return c;
  endfunction
endpackage

module dut (output logic [31:0] o);
  // The module-body namesakes: the widths `bindVariable` will answer with.
  logic [7:0]  n_nar;    // int member onto an 8-bit namesake
  logic [63:0] n_wid;    // int member onto a 64-bit namesake
  logic [7:0]  w_nar;    // logic[39:0] member onto an 8-bit namesake
  logic [63:0] w_wid;    // logic[39:0] member onto a 64-bit namesake
  logic [31:0] b_any;    // byte member onto a 32-bit namesake
  logic [31:0] nons;     // the control: NO namesake for `only`
  for (genvar i = 0; i < 1; i = i + 1) begin : gw
    localparam p::cfg_t G = p::build(321);
    logic [31:0] n_nar; assign n_nar = G.n;
    logic [31:0] n_wid; assign n_wid = G.n;
    logic [31:0] w_nar; assign w_nar = G.w;
    logic [31:0] w_wid; assign w_wid = G.w;
    logic [31:0] b_any; assign b_any = G.b;
    logic [31:0] only;  assign only  = G.n;   // no namesake -> lhsw 0
  end
  assign o = gw[0].n_nar ^ gw[0].n_wid ^ gw[0].w_nar ^ gw[0].w_wid
           ^ gw[0].b_any ^ gw[0].only ^ n_nar ^ n_wid ^ w_nar ^ w_wid
           ^ b_any ^ nons;
endmodule
