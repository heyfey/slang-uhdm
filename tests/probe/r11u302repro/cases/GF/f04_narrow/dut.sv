// § elabImpSelFlatKeepsParent302
// f04: a narrow (<= 64-bit) packed pattern selected in its package
package p;
  typedef struct packed { logic [15:0] a; logic [15:0] b; } n_t;
  localparam n_t NS = '{a: 16'd4, b: 16'd5};
  localparam n_t NN = '{a: 16'd6, b: 16'd7};
  typedef logic [NS.a-1:0] v_t;
endpackage
module q import p::*; (input logic clk);
  v_t d;
  assign d = '0;
endmodule
module dut(input logic clk);
  q u_q (.clk(clk));
endmodule
