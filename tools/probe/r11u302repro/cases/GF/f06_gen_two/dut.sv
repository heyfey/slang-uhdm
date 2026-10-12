// § elabImpSelFlatKeepsParent302
// f06: two instances, one under a generate block, depth 2
package p7;
  typedef struct packed { logic [31:0] a; logic [31:0] b; logic [31:0] c; } w7_t;
  localparam w7_t WSEL = '{a: 32'd4, b: 32'd5, c: 32'd6};
  typedef logic [WSEL.b-1:0] w1_t;
endpackage
module q import p7::*; (input logic clk);
  w1_t d;
  assign d = '0;
endmodule
module mid(input logic clk);
  q u0 (.clk(clk));
  if (1) begin : g
    q u1 (.clk(clk));
  end
endmodule
module dut(input logic clk);
  mid m (.clk(clk));
endmodule
