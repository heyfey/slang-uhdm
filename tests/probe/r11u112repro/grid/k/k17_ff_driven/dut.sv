module top(input logic clk, input logic [31:0] i, output logic [31:0] o);
  localparam type my_t = struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; };
  my_t s;
  my_t [1:0] arr;
  always_ff @(posedge clk) begin s.a <= i; arr[1].a <= i; end
  assign o = s.a + arr[1].a;
endmodule
