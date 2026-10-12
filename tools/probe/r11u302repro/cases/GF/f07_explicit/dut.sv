// § elabImpSelFlatKeepsParent302
// f07: an explicit import of the selected parameter, body import
package p7;
  typedef struct packed { logic [31:0] a; logic [31:0] b; logic [31:0] c; } w7_t;
  localparam w7_t WSEL = '{a: 32'd4, b: 32'd5, c: 32'd6};
  typedef logic [WSEL.c-1:0] w1_t;
endpackage
module q (input logic clk);
  import p7::WSEL;
  p7::w1_t d;
  assign d = '0;
endmodule
module dut(input logic clk);
  q u_q (.clk(clk));
endmodule
