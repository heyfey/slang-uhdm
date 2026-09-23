module m(input logic clk, input logic [7:0] x, output logic [7:0] y);
  typedef logic [7:0] b_t;
  task automatic t(input logic [7:0] v, output b_t o); o = b_t'(v + 8'd3); endtask
  always_ff @(posedge clk) begin b_t r; t(x, r); y <= r; end
endmodule
