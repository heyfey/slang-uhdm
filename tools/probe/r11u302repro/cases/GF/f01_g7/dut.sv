// § elabImpSelFlatKeepsParent302
// f01: a wide packed pattern selected in its package (typedef range) beside a never-read sibling
package p7;
  typedef struct packed { logic [31:0] a; logic [31:0] b; logic [31:0] c; } w7_t;
  localparam w7_t WNON = '{a: 32'd1, b: 32'd2, c: 32'd3};
  localparam w7_t WSEL = '{a: 32'd4, b: 32'd5, c: 32'd6};
  typedef logic [WSEL.a-1:0] w1_t;
endpackage
module q import p7::*; (input logic clk);
  w1_t d;
  assign d = '0;
endmodule
module dut(input logic clk);
  q u_q (.clk(clk));
endmodule
