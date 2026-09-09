// r10v225 arm v7_ports — a PORT whose net carries an unpacked dimension.  The
// array_net block sits OUTSIDE the `if (!it.port …)` typespec guard, so a port
// net reaches it too; golden's `writeNets` walks the same Signal vector.
// Both header forms, and an interface with a real non-ANSI header.
typedef logic [7:0] tvp_t;

interface if225v_ansi(input logic clk, input tvp_t pin [1:0],
                      output tvp_t pout [3]);
  tvp_t b_fix [1:0];
  tvp_t b_dyn [];
endinterface

interface if225v_na(pa, pb);
  input pa;
  output tvp_t pb [1:0];
  tvp_t c_fix [1:0];
  tvp_t c_as  [string];
endinterface

module top225v_p();
  logic clk;
  tvp_t a [1:0];
  tvp_t b [3];
  tvp_t d [1:0];
  logic e;
  if225v_ansi u_a(.clk(clk), .pin(a), .pout(b));
  if225v_na   u_n(e, d);
endmodule
