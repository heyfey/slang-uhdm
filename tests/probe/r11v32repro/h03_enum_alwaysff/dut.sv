package p; typedef enum logic [2:0] {A,B} e_t; endpackage
module ch (input logic clk, output logic s);
  import p::*;
  e_t [1:0] r;
  always_ff @(posedge clk) r <= r;
  assign s = |r;
endmodule
module top; logic clk, s; ch i0(.clk(clk), .s(s)); endmodule
