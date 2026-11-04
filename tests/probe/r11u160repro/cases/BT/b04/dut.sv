// § bodyTypeParamDefaultBound160
module child (input logic clk, output logic [63:0] sum);
  localparam type my_t = struct packed { logic [31:0] a; logic [15:0] b; };
  my_t        scalar_sig;
  my_t [2:0]  arr;
  always_ff @(posedge clk) begin scalar_sig <= '0; arr <= '0; end
  assign sum = scalar_sig.a + arr[0].a;
endmodule
module top (input logic clk, output logic [63:0] sum);
  child c (.clk(clk), .sum(sum));
endmodule
