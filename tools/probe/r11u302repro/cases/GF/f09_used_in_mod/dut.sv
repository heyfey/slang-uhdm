// § elabImpSelFlatKeepsParent302
// f09: package-selected and also read in the importing module in slots
package p7;
  typedef struct packed { logic [31:0] a; logic [31:0] b; logic [31:0] c; } w7_t;
  localparam w7_t WSEL = '{a: 32'd4, b: 32'd5, c: 32'd2};
  typedef logic [WSEL.a-1:0] w1_t;
endpackage
module q import p7::*; (input logic [15:0] i, output logic [7:0] o);
  w1_t d;
  assign d = i[WSEL.a-1:0];
  assign o = {WSEL.c{d}};
endmodule
module dut(input logic [15:0] i, output logic [7:0] o);
  q u_q (.i(i), .o(o));
endmodule
