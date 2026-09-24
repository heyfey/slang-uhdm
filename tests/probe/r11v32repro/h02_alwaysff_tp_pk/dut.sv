module ch #(parameter type T = logic [7:0]) (input logic clk, output logic s);
  T [1:0] r;
  always_ff @(posedge clk) r <= r + 1;
  assign s = |r;
endmodule
module top; logic clk, s; ch i0(.clk(clk), .s(s)); endmodule
