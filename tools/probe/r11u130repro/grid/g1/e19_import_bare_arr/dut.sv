// § defNetEndOnlyLoc130
package p; typedef enum logic [2:0] {A,B} e_t; typedef struct packed { logic a; } s_t; endpackage
module ch (input logic clk, output logic s);
  import p::*;
  e_t [1:0] r;
  s_t [2:0][1:0] q;
  always_ff @(posedge clk) r <= r;
  assign q = '0;
  assign s = |r;
endmodule
module top; logic clk, s; ch i0(.clk(clk), .s(s)); endmodule
