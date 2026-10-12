// § elabImpSelFlatKeepsParent302
// vg01: the package selects WSEL in a localparam initializer, not in a typedef
package p7;
  typedef struct packed { logic [31:0] a; logic [31:0] b; logic [31:0] c; } w7_t;
  localparam w7_t WNON = '{a: 32'd1, b: 32'd2, c: 32'd3};
  localparam w7_t WSEL = '{a: 32'd4, b: 32'd5, c: 32'd6};
  localparam int WA = WSEL.a;
endpackage
module q import p7::*; (input logic clk, output logic [31:0] o);
  assign o = WA;
endmodule
module dut(input logic clk, output logic [31:0] o);
  q u_q (.clk(clk), .o(o));
endmodule
